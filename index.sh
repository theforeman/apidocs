#!/bin/bash
tree -d -H '.' -L 2 --noreport -T "Foreman API documentation" -I TEMPLATE --charset utf-8 > index.html
