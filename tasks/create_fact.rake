# frozen_string_literal: true

desc 'Create a fact template for the specified arguments'
task :create_fact, [:os, :fact_name] do |_, args|
  require_relative 'fact_generator/fact_creator'

  abort 'Usage: rake \'create_facts[os,fact_name]\'' if !args[:os] || !args[:fact_name]

  fact_creator = FactCreator.new
  fact_creator.create_fact(args[:os], args[:fact_name])
end

desc 'Create one or multiple facts by reading descriptions from facts.json'
task :create_facts do
  require_relative 'fact_generator/fact_creator'

  fact_creator = FactCreator.new
  fact_creator.create_facts
end
