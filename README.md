# Foreman API documentation

Generated HTML API documentation for the [Foreman](https://www.theforeman.org)
and its plugins via [apipie-rails](https://github.com/Apipie/apipie-rails).

The content is hosted at [https://apidocs.theforeman.org](https://apidocs.theforeman.org)

For Foreman documentation go to [https://docs.theforeman.org](https://docs.theforeman.org)

## Managing Foreman Versions

### Foreman

To add or update a Foreman version:

```bash
make foreman-version VERSION=X.Y
```

This downloads apidocs from GitHub Actions and either:
- **New version**: Creates directory, updates index.html, sets `latest` symlink (if newest)
- **Existing version**: Updates apidoc files, preserves static assets (CSS/JS)

Individual steps:
```bash
make foreman-download VERSION=X.Y        # Download only
./scripts/foreman-process-version.sh X.Y # Process after manual download
make cleanup                              # Remove i18n/JSON files
```

### Katello

**Step 1: Generate API docs in a Foreman + Katello development environment**

1. cd to the katello directory and checkout the relevant release branch
1. cd to the foreman directory and checkout the relevant stable branch
1. `APIPIE_RECORD=examples bundle exec rake test`
1. `RAILS_ENV=production FOREMAN_APIPIE_LANGS=en bundle exec rake apipie:cache`

**Step 2: Prepare folder for the new version (X.Y)**

In the apidocs repository root:

1. `cp -r katello/TEMPLATE katello/X.Y`
1. `ln -snf X.Y katello/latest`
1. `cp -r /path/to/foreman/public/apipie-cache/apidoc/* katello/X.Y/apidoc`
1. Update index.html with a link to the new version
1. Run cleanup script: `./scripts/cleanup.sh`

## LICENSE

All files are auto-generated and distributed under GNU GPL v3 conditions. See
the LICENSE file for more info.
