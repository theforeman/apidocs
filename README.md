# Foreman API documentation

Generated HTML API documentation for the [Foreman](https://www.theforeman.org)
and its plugins via [apipie-rails](https://github.com/Apipie/apipie-rails).

The content is hosted at [https://apidocs.theforeman.org](https://apidocs.theforeman.org)

For Foreman documentation go to [https://docs.theforeman.org](https://docs.theforeman.org)

## Adding new version

Follow these steps to add a new version:

### Foreman

Fetch API docs for Foreman:

1. Go to https://github.com/theforeman/foreman/actions/workflows/foreman.yml?query=branch%3AX.Y-stable
1. Pick the latest run of the action
1. Download the `apidoc-*` artifact (there might be multiple, pick any one of them)

You can also do this from the CLI using `gh`:
```
gh run download --repo theforeman/foreman --pattern 'apidoc-*' $(gh run list --repo theforeman/foreman --workflow foreman.yml --branch X.Y-stable --status completed --limit 1 --json databaseId --jq '.[].databaseId')
```
Note: `gh` will automatically unzip the artifacts, so you only have to copy them.

Prepare folder for the new version (X.Y)

1. `cd foreman`
1. `cp -r TEMPLATE X.Y`
1. `ln -snf X.Y latest`
1. `unzip -d X.Y/apidoc ~/Downloads/apidoc-<…>.zip`
1. run cleanup script in the root of the apidocs repo: `cleanup.sh`
1. update index.html file with a link to the new page

### Katello

Generate API docs in a Foreman + Katello development environment:

1. cd to the katello directory and checkout the relevant release branch
1. cd to the foreman directory and checkout the relevant stable branch
1. `APIPIE_RECORD=examples bundle exec rake test`
1. `RAILS_ENV=production FOREMAN_APIPIE_LANGS=en bundle exec rake apipie:cache`

Prepare folder for the new version (X.Y)

1. cd to the apidocs/katello directory
1. `cp -r TEMPLATE X.Y`
1. `ln -snf X.Y latest`
1. `cp -r dir/to/foreman/public/apipie-cache/apidoc/* X.Y/apidoc`
1. run cleanup script in apidocs repo: `cleanup.sh`
1. update index.html file with a link to the new page

## LICENSE

All files are auto-generated and distributed under GNU GPL v3 conditions. See
the LICENSE file for more info.
