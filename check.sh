#!/usr/bin/env bash

set -e

# run unit tests
rspec

# run linting
rubocop

# run lint with ui
rubycritic