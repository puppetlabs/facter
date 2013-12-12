#!/usr/bin/env ruby

require 'json'
require 'json-schema'

facts  = `bundle exec facter --json`
schema = JSON.parse(File.read("schema/facter.json"))
JSON::Validator.validate!(schema, facts)
