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

gh run download --repo Katello/katello --pattern 'apidoc-*' "$RUN_ID"

echo "Download complete. Artifact saved to current directory."
