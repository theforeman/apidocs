#!/bin/bash
set -e

VERSION="$1"

if [ -z "$VERSION" ]; then
    echo "ERROR: VERSION is required"
    echo "Usage: $0 X.Y"
    exit 1
fi

echo "Downloading apidoc artifact for Foreman $VERSION..."
gh run download --repo theforeman/foreman --pattern 'apidoc-*' \
    $(gh run list --repo theforeman/foreman --workflow foreman.yml \
    --branch "${VERSION}-stable" --status completed --limit 1 \
    --json databaseId --jq '.[].databaseId')

echo "Download complete. Artifact saved to current directory."
