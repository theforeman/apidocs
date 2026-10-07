#!/bin/bash
set -e

VERSION="$1"

if [ -z "$VERSION" ]; then
    echo "ERROR: VERSION is required"
    echo "Usage: $0 X.Y"
    exit 1
fi

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: VERSION must be in X.Y format (e.g., 4.21)"
    exit 1
fi

# Find downloaded artifact
APIDOC_DIR=$(find . -maxdepth 1 -type d -name 'apidoc-*' | sort | head -n 1)
if [ -z "$APIDOC_DIR" ]; then
    echo "ERROR: No apidoc-* directory found. Run katello-download.sh first"
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

echo "Cleaning up downloaded artifact..."
find . -maxdepth 1 -type d -name 'apidoc-*' -exec rm -rf {} +
