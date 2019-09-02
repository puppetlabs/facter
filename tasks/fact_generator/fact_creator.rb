#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'pathname'
require 'fileutils'
require 'erb'

ROOT_DIR = Pathname.new(File.expand_path('../..', __dir__)) unless defined?(ROOT_DIR)

class FactCreator
  def create_facts
    facts_json_string = File.read(File.join(ROOT_DIR, 'tasks', 'fact_generator', 'facts.json'))
    facts = JSON.parse(facts_json_string)

    facts.each do |fact|
      operating_system =  fact['os']
      fact_name = fact['fact_name']

      path = create_directory_path(operating_system, fact_name)
      create_directory_structure(path)
      create_fact_file(path, fact_name, operating_system)
    end
  end

  def create_fact(operating_system, fact_name)

    puts fact_name
    puts operating_system

    path = create_directory_path(operating_system, fact_name)
    create_directory_structure(path)
    create_fact_file(path, fact_name, operating_system)
  end

  private

  def create_directory_path(operating_system, fact_name)
    fact_tokens = fact_name.split('.')
    fact_tokens = fact_tokens.first(fact_tokens.size - 1)

    File.join(ROOT_DIR, 'lib', 'facts', operating_system, fact_tokens)
  end

  def create_directory_structure(path)
    unless File.directory?(path)
      FileUtils.mkdir_p(path)
    end
  end

  def create_fact_file(path, fact_name, operating_system)
    fact_tokens = fact_name.split('.')
    fact_file_name = fact_tokens.reverse.first + '.rb'
    fact_file_with_path = File.join(path, fact_file_name)

    unless File.exist?(fact_file_with_path)
      fact_file = File.new(File.join(path, fact_file_name), 'w')

      fact_class_content = create_fact_from_template(fact_name, operating_system)
      fact_file.write(fact_class_content)
    end
  end

  def create_fact_from_template(fact_name, operating_system)
    fact_tokens = fact_name.split('.')
    template = ERB.new(File.read(File.join(ROOT_DIR,'tasks', 'fact_generator', 'fact.erb')))

    os_name = operating_system.capitalize
    camelcase_fact_name = fact_tokens.map {|token| token.capitalize}.join('')
    template.result( binding )
  end

end
