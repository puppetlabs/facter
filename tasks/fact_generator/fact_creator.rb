#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'pathname'
require 'fileutils'
require 'erb'

ROOT_DIR = Pathname.new(File.expand_path('../..', __dir__)) unless defined?(ROOT_DIR)

require "#{ROOT_DIR}/tasks/fact_generator/path"
require "#{ROOT_DIR}/lib/framework/logging/multilogger"
require "#{ROOT_DIR}/lib/framework/logging/logger"

class FactCreator
  def initialize
    @log = Facter::Log.new
  end

  def create_facts
    facts_json_string = File.read(File.join(ROOT_DIR, 'tasks', 'fact_generator', 'facts.json'))
    facts = JSON.parse(facts_json_string)

    facts.each do |fact|
      operating_system = fact['os']
      fact_name = fact['fact_name']
      create_fact(operating_system, fact_name)
    end
  end

  def create_fact(operating_system, fact_name)
    @log.info("Creating fact with name #{fact_name} for os #{operating_system}")

    path = create_directory_path(operating_system, fact_name)
    create_directory_structure(path)

    create_fact_files(path, fact_name, operating_system)
  end

  private

  def create_directory_path(operating_system, fact_name)
    fact_tokens = fact_name.split('.')
    fact_tokens = fact_tokens.first(fact_tokens.size - 1)

    fact_directory = File.join(ROOT_DIR, 'lib', 'facts', operating_system, fact_tokens)
    fact_spec_directory = File.join(ROOT_DIR, 'spec', 'facter', 'facts', operating_system, fact_tokens)
    Path.new(fact_directory, fact_spec_directory)
  end

  def create_directory_structure(path)
    FileUtils.mkdir_p(path.fact) unless File.directory?(path.fact)
    FileUtils.mkdir_p(path.spec) unless File.directory?(path.spec)
  end

  def create_fact_files(path, fact_name, operating_system)
    create_fact_file(path.fact, fact_name, operating_system)
    create_spec_file(path.spec, fact_name, operating_system)
  end

  def create_fact_file(fact_path, fact_name, operating_system)
    fact_tokens = fact_name.split('.')
    fact_file_name = fact_tokens.reverse.first + '.rb'
    fact_file_with_path = File.join(fact_path, fact_file_name)

    return if File.exist?(fact_file_with_path)

    fact_file = File.new(File.join(fact_path, fact_file_name), 'w')
    fact_class_content = create_fact_from_template(fact_name, operating_system)
    fact_file.write(fact_class_content)
  end

  def create_spec_file(spec_path, fact_name, operating_system)
    fact_tokens = fact_name.split('.')
    spec_file_name = fact_tokens.reverse.first + '_spec.rb'
    spec_file_with_path = File.join(spec_path, spec_file_name)

    return if File.exist?(spec_file_with_path)

    spec_file = File.new(File.join(spec_path, spec_file_name), 'w')
    spec_class_content = create_spec_from_template(fact_name, operating_system)
    spec_file.write(spec_class_content)
  end

  def create_fact_from_template(fact_name, operating_system)
    delimiters = ['.', '_']
    fact_tokens = fact_name.split(Regexp.union(delimiters))
    template = ERB.new(File.read(File.join(ROOT_DIR, 'tasks', 'fact_generator', 'fact.erb')))

    os_name = operating_system.capitalize
    camelcase_fact_name = fact_tokens.map(&:capitalize).join('')
    template.result(binding)
  end

  def create_spec_from_template(fact_name, operating_system)
    delimiters = ['.', '_']
    fact_tokens = fact_name.split(Regexp.union(delimiters))
    template = ERB.new(File.read(File.join(ROOT_DIR, 'tasks', 'fact_generator', 'fact_spec.erb')))

    os_name = operating_system.capitalize
    camelcase_fact_name = fact_tokens.map(&:capitalize).join('')
    template.result(binding)
  end
end
