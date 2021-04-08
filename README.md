# Foreman API documentation

Generated HTML API documentation for the [Foreman](https://www.theforeman.org)
and its plugins via [apipie-rails](https://github.com/Apipie/apipie-rails).

The content is hosted at [https://apidocs.theforeman.org](https://apidocs.theforeman.org)

For Foreman documentation go to [https://docs.theforeman.org](https://docs.theforeman.org)

## Adding new version

Follow these steps to add a new version:

### Foreman

Generate API docs in Foreman:

1. cd to foreman directory and checkout the relevant stable branch
1. disable any plugins installed locally
1. `APIPIE_RECORD=examples rake test`
1. `FOREMAN_APIPIE_LANGS=en rake apipie:cache`

Prepare folder for the new version (X.Y)

1. cd to apidocs/foreman directory
1. `cp -r TEMPLATE X.Y`
1. `ln -sf X.Y latest`
1. `cp -r dir/to/foreman/public/apipie-cache/apidoc/* Y.Y/apidoc`
1. run cleanup script in apidoc repo: `cleanup.sh`

## LICENSE

All files are auto-generated and distributed under GNU GPL v3 conditions. See
the LICENSE file for more info.
