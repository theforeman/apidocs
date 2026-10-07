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
The CI uploads one `apidoc-*` artifact per Ruby version; they have identical
content and the first one is used.

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
picks up and removes afterwards.

## LICENSE

All files are auto-generated and distributed under GNU GPL v3 conditions. See
the LICENSE file for more info.
