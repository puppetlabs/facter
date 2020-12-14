#!/usr/bin/env bash

set -e

echo "<------------- Running unit tests ------------->"
bundle exec rspec --order random

echo "<------------- Running integration tests ------------->"
bundle exec rspec --order random spec/integration --tag integration

echo "<------------- Running rubocop ------------->"
bundle exec rubocop --parallel

# It will be disabled untill we rewrite it's rules
# rubycritic --no-browser -f console
