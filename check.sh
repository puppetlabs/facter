#!/usr/bin/env bash

set -e

# run unit tests
rspec

# run linting
rubocop

# It will be disabled untill we rewrite it's rules
# rubycritic --no-browser -f console
