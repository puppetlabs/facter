#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'thor'
require "#{ROOT_DIR}/lib/facter-ng"
require "#{ROOT_DIR}/lib/framework/cli/cli"

Facter::OptionsValidator.validate(ARGV)
ARGV.unshift(Facter::Cli.default_task) unless
  Facter::Cli.all_tasks.key?(ARGV[0]) ||
  Facter::Cli.instance_variable_get(:@map).key?(ARGV[0])

begin
  Facter::Cli.start(ARGV, debug: true)
rescue Thor::UnknownArgumentError => e
  Facter::OptionsValidator.write_error_and_exit("unrecognised option '#{e.unknown.first}'")
end
