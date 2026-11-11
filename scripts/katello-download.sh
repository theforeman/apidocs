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

echo "Downloading apidoc artifact for Katello $VERSION..."
# Artifacts are only uploaded by successful push runs (not by PR runs)
RUN_ID=$(gh run list --repo Katello/katello --workflow ruby.yml \
    --branch "KATELLO-${VERSION}" --status success --event push --limit 1 \
    --json databaseId --jq '.[].databaseId')

if [ -z "$RUN_ID" ]; then
    echo "ERROR: No successful ruby.yml push run found for branch KATELLO-${VERSION}"
    exit 1
fi

# Download to a temporary directory, so a failed download leaves existing files alone
DOWNLOAD_DIR=$(mktemp -d)
trap 'rm -rf "$DOWNLOAD_DIR"' EXIT

gh run download --repo Katello/katello --pattern 'apidoc-katello-*' --dir "$DOWNLOAD_DIR" "$RUN_ID" || {
    echo "ERROR: No apidoc-katello-* artifact in run $RUN_ID (expired, or generate_apidoc not enabled on KATELLO-${VERSION})"
    exit 1
}

# Replace artifacts from a previous download only
find . -maxdepth 1 -type d -name 'apidoc-katello-*' -exec rm -rf {} +
mv "$DOWNLOAD_DIR"/apidoc-katello-* .

echo "Download complete. Artifact saved to current directory."
