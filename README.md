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

To add or update a Katello version:

```bash
make katello-version VERSION=X.Y
```

This downloads apidocs from the latest successful `ruby.yml` push run of the
`KATELLO-X.Y` branch in GitHub Actions and either:
- **New version**: Creates directory, updates index.html, sets `latest` symlink (if newest)
- **Existing version**: Updates apidoc files, preserves static assets (CSS/JS)

Individual steps:
```bash
make katello-download VERSION=X.Y        # Download only
./scripts/katello-process-version.sh X.Y # Process after manual download
make cleanup                              # Remove i18n/JSON files
```

The artifacts only exist if the Katello CI has `generate_apidoc` enabled (an
input of the `foreman_plugin.yml` workflow in
[theforeman/actions](https://github.com/theforeman/actions)) on that branch.
The CI uploads one `apidoc-*` artifact per Ruby version. The API descriptions
are the same, but the recorded examples can differ, because they come from the
test runs; the process script uses the artifact for the newest Ruby.

To do it manually, download an `apidoc-*` artifact from
https://github.com/Katello/katello/actions/workflows/ruby.yml?query=branch%3AKATELLO-X.Y
(pick a successful run) or use `gh`:
```bash
gh run download --repo Katello/katello --pattern 'apidoc-*' \
    $(gh run list --repo Katello/katello --workflow ruby.yml --branch KATELLO-X.Y \
    --status success --event push --limit 1 --json databaseId --jq '.[].databaseId')
./scripts/katello-process-version.sh X.Y
make cleanup
```
`gh` unzips the artifacts into `apidoc-*` directories, which the process script
picks up and removes afterwards. If other `apidoc-*` directories are present,
pass the one to use as the second argument; a directory passed this way is not
removed.

For branches without artifacts (e.g. `KATELLO-4.21` and older), generate the
docs in a Foreman + Katello development environment:
1. cd to the katello directory and checkout the relevant release branch
1. cd to the foreman directory and checkout the relevant stable branch
1. `APIPIE_RECORD=examples bundle exec rake test:katello`
1. `RAILS_ENV=production FOREMAN_APIPIE_LANGS=en bundle exec rake apipie:cache`
1. In the apidocs repository root:
   ```bash
   cp -r /path/to/foreman/public/apipie-cache/apidoc apidoc-local
   ./scripts/katello-process-version.sh X.Y apidoc-local
   make cleanup
   rm -rf apidoc-local
   ```

## LICENSE

All files are auto-generated and distributed under GNU GPL v3 conditions. See
the LICENSE file for more info.
