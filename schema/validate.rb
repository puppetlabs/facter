#!/usr/bin/env ruby

require 'json'
require 'json-schema'

facts  = `bundle exec facter --json`
schema = JSON.parse(File.read("schema/facter.json"))
errors =  JSON::Validator.fully_validate(schema, facts)
if errors.empty?
  puts "Passed validation!"
  exit 0
else
  puts errors
  puts "Failed validation."
  exit 1
end
