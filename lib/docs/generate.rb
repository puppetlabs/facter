#!/usr/bin/env ruby
# Generates a markdown file containing fact documentation.
# usage: ruby generate.rb > facts.md

require 'yaml'
require 'erb'
require 'ostruct'

PATH_TO_SCHEMA = File.join(File.dirname(__FILE__), '../schema/facter.yaml')
PATH_TO_TEMPLATE = File.join(File.dirname(__FILE__), 'template.erb')

scope = OpenStruct.new({
  :facts => YAML.load_file(PATH_TO_SCHEMA)
})

puts ERB.new(File.read(PATH_TO_TEMPLATE), nil, '-').result(scope.instance_eval {binding})