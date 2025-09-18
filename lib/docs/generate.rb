#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates a markdown file containing fact documentation.
# usage: ruby generate.rb > facts.md

require 'yaml'
require 'erb'
require 'ostruct'

PATH_TO_SCHEMA = File.join(File.dirname(__FILE__), '../schema/facter.yaml')
PATH_TO_TEMPLATE = File.join(File.dirname(__FILE__), 'template.erb')

schema = YAML.load_file(PATH_TO_SCHEMA)

def format_facts(fact_hash)
  scope = OpenStruct.new({
                           facts: fact_hash
                         })

  erb = if ERB.instance_method(:initialize).parameters.assoc(:key) # Ruby 2.6+
          ERB.new(File.read(PATH_TO_TEMPLATE), trim_mode: '-')
        else
          ERB.new(File.read(PATH_TO_TEMPLATE), trim_mode: '-')
        end
  erb.result(scope.instance_eval { binding })
end

print "## Modern Facts\n\n"
print format_facts(schema.reject { |_name, info| info['hidden'] == true })
print "## Legacy Facts\n\n"
print format_facts(schema.reject { |_name, info| info['hidden'].nil? || info['hidden'] == false })
