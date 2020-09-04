#!/usr/bin/env ruby
# frozen_string_literal: true

require 'facter/framework/logging/logger.rb'
Facter::Log.output(STDERR)
require 'facter'
require 'facter/framework/cli/cli'

class CliLauncher
  class << self
    def prepare_arguments(args, task = Facter::Cli.default_task)
      args.unshift(task) unless
        check_if_arguments_is_known(Facter::Cli.all_tasks, args) ||
        check_if_arguments_is_known(Facter::Cli.instance_variable_get(:@map), args) ||
        !task

      reorder_program_arguments(args)
    end

    def start(args)
      # stop parsing arguments if we don't recognize them
      Thor.check_unknown_options!
      Facter::Cli.start(args, debug: true)
    rescue Thor::UnknownArgumentError => e
      Facter::OptionsValidator.write_error_and_exit("unrecognised option '#{e.unknown.first}'")
    end

    private

    def check_if_arguments_is_known(known_arguments, program_arguments)
      program_arguments.each do |argument|
        return true if known_arguments.key?(argument)
      end

      false
    end

    def reorder_program_arguments(program_arguments)
      priority_arguments = Facter::Cli.instance_variable_get(:@map)

      priority_args = []
      normal_args = []

      program_arguments.each do |argument|
        if priority_arguments.include?(argument)
          priority_args << argument
        else
          normal_args << argument
        end
      end

      priority_args.concat(normal_args)
    end
  end
end
