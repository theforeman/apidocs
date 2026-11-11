#!/bin/bash
set -e

VERSION="$1"
APIDOC_DIR="$2"

if [ -z "$VERSION" ]; then
    echo "ERROR: VERSION is required"
    echo "Usage: $0 X.Y [APIDOC_DIR]"
    exit 1
fi

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: VERSION must be in X.Y format (e.g., 4.21)"
    exit 1
fi

if [ -z "$APIDOC_DIR" ]; then
    # Find downloaded artifact; with one per Ruby version, use the newest Ruby
    mapfile -t CANDIDATES < <(find . -maxdepth 1 -type d -name 'apidoc-*' | sort -rV)
    if [ ${#CANDIDATES[@]} -eq 0 ]; then
        echo "ERROR: No apidoc-* directory found. Run katello-download.sh first"
        exit 1
    fi
    if [ ${#CANDIDATES[@]} -gt 1 ] && printf '%s\n' "${CANDIDATES[@]}" | grep -qv '^\./apidoc-katello-'; then
        echo "ERROR: Multiple apidoc-* directories found: ${CANDIDATES[*]}"
        echo "Pass the one to use: $0 $VERSION APIDOC_DIR"
        exit 1
    fi
    APIDOC_DIR="${CANDIDATES[0]}"
fi

if [ ! -s "$APIDOC_DIR/v2.html" ] || [ -z "$(find "$APIDOC_DIR/v2" -name '*.html' -print -quit 2>/dev/null)" ]; then
    echo "ERROR: $APIDOC_DIR does not look like an apidoc artifact (missing v2.html or v2/*.html)"
    exit 1
fi

if [ -d "katello/$VERSION" ]; then
    echo "Updating existing version $VERSION..."

    echo "Removing old apidoc files (preserving static assets)..."
    find "katello/$VERSION/apidoc" -mindepth 1 -maxdepth 1 \
        ! -name 'javascripts' \
        ! -name 'stylesheets' \
        -exec rm -rf {} +

    echo "Copying new apidoc files..."
    cp -r "$APIDOC_DIR"/* "katello/$VERSION/apidoc/"

    echo "Successfully updated Katello $VERSION apidocs"
else
    echo "Creating new version $VERSION..."

    echo "Setting up directory structure from TEMPLATE..."
    cp -r katello/TEMPLATE "katello/$VERSION"

    echo "Copying apidoc files..."
    cp -r "$APIDOC_DIR"/* "katello/$VERSION/apidoc/"

    echo "Updating index.html..."
    sed -i "s|./katello/latest/apidoc/v2.html\">latest</a></li>|\0\n\t\t<li><a href=\"./katello/$VERSION/apidoc/v2.html\">$VERSION</a></li>|" index.html

    CURRENT_LATEST=$(readlink katello/latest 2>/dev/null || echo "")
    if [ -z "$CURRENT_LATEST" ]; then
        echo "Setting 'latest' symlink to $VERSION (no existing latest)..."
        ln -snf "$VERSION" katello/latest
    else
        # Compare versions using sort -V (version sort)
        # If VERSION is the highest when sorted, it should be latest
        HIGHEST=$(printf '%s\n' "$VERSION" "$CURRENT_LATEST" | sort -rV | head -n1)
        if [ "$HIGHEST" = "$VERSION" ]; then
            echo "Updating 'latest' symlink to $VERSION (newer than $CURRENT_LATEST)..."
            ln -snf "$VERSION" katello/latest
        else
            echo "Not updating 'latest' symlink (current latest $CURRENT_LATEST is newer than $VERSION)"
        fi
    fi

    echo "Successfully created Katello $VERSION"
fi

echo "Cleaning up artifacts..."
rm -rf "$APIDOC_DIR"
find . -maxdepth 1 -type d -name 'apidoc-katello-*' -exec rm -rf {} +
