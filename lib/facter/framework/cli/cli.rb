#!/usr/bin/env ruby
# frozen_string_literal: true

require 'thor'

module Facter
  class Cli < Thor
    class_option :color,
                 type: :boolean,
                 desc: 'Enable color output.'

    class_option :no_color,
                 type: :boolean,
                 desc: 'Disable color output.'

    class_option :config,
                 aliases: '-c',
                 type: :string,
                 desc: 'The location of the config file.'

    class_option :custom_dir,
                 type: :string,
                 repeatable: true,
                 desc: 'A directory to use for custom facts.'

    class_option :debug,
                 aliases: '-d',
                 type: :boolean,
                 desc: 'Enable debug output.'

    class_option :external_dir,
                 type: :string,
                 repeatable: true,
                 desc: 'A directory to use for external facts.'

    class_option :hocon,
                 type: :boolean,
                 desc: 'Output in Hocon format.'

    class_option :json,
                 aliases: '-j',
                 type: :boolean,
                 desc: 'Output in JSON format.'

    class_option :log_level,
                 aliases: '-l',
                 type: :string,
                 desc: 'Set logging level. Supported levels are: none, trace, debug, info, warn, error, and fatal.'

    class_option :no_block,
                 type: :boolean,
                 desc: 'Disable fact blocking.'

    class_option :no_cache,
                 type: :boolean,
                 desc: 'Disable loading and refreshing facts from the cache'

    class_option :no_custom_facts,
                 type: :boolean,
                 desc: 'Disable custom facts.'

    class_option :no_external_facts,
                 type: :boolean,
                 desc: 'Disable external facts.'

    class_option :no_ruby,
                 type: :boolean,
                 desc: 'Disable loading Ruby, facts requiring Ruby, and custom facts.'

    class_option :trace,
                 type: :boolean,
                 desc: 'Enable backtraces for custom facts.'

    class_option :verbose,
                 type: :boolean,
                 desc: 'Enable verbose (info) output.'

    class_option :show_legacy,
                 type: :boolean,
                 desc: 'Show legacy facts when querying all facts.'

    class_option :yaml,
                 aliases: '-y',
                 type: :boolean,
                 desc: 'Output in YAML format.'

    class_option :strict,
                 type: :boolean,
                 desc: 'Enable more aggressive error reporting.'

    class_option :timing,
                 type: :boolean,
                 aliases: '-t',
                 desc: 'Show how much time it took to resolve each fact'

    class_option :sequential,
                 type: :boolean,
                 desc: 'Resolve facts sequentially'

    desc '--man', 'Display manual.', hide: true
    map ['--man'] => :man
    def man(*args)
      require 'erb'
      negate_options = %w[block cache custom_facts external_facts]

      template = File.join(File.dirname(__FILE__), '..', '..', 'templates', 'man.erb')
      erb = ERB.new(File.read(template), nil, '-')
      erb.filename = template
      puts erb.result(binding)
    end

    desc 'query', 'Default method', hide: true
    def query(*args)
      output, status = Facter.to_user_output(@options, *args)
      puts output

      status = 1 if Facter::Log.errors?
      exit status
    end

    desc 'arg_parser', 'Parse arguments', hide: true
    def arg_parser(*args)
      # ignore unknown options
      args.reject! { |arg| arg.start_with?('-') }

      Facter.values(@options, args)
    end

    desc '--version, -v', 'Print the version', hide: true
    map ['--version', '-v'] => :version
    def version(*_args)
      puts Facter::VERSION
    end

    desc '--list-block-groups', 'List block groups'
    map ['--list-block-groups'] => :list_block_groups
    def list_block_groups(*args)
      options = @options.map { |(k, v)| [k.to_sym, v] }.to_h
      Facter::Options.init_from_cli(options, args)

      block_groups = Facter::FactGroups.new.groups.to_yaml.lines[1..-1].join
      block_groups.gsub!(/:\s*\n/, "\n")

      puts block_groups
    end

    desc '--list-cache-groups', 'List cache groups'
    map ['--list-cache-groups'] => :list_cache_groups
    def list_cache_groups(*args)
      options = @options.map { |(k, v)| [k.to_sym, v] }.to_h
      Facter::Options.init_from_cli(options, args)

      cache_groups = Facter::FactGroups.new.groups.to_yaml.lines[1..-1].join
      cache_groups.gsub!(/:\s*\n/, "\n")

      puts cache_groups
    end

    desc '--puppet, -p', '(NOT SUPPORTED)Load the Puppet libraries, thus allowing Facter to load Puppet-specific facts.'
    map ['--puppet', '-p'] => :puppet
    def puppet(*args)
      log = Log.new(self)
      log.warn('`facter --puppet` and `facter -p` are no longer supported, use `puppet facts show` instead')
      log.warn('the output does not contain puppet facts!')

      output, status = Facter.to_user_output(@options, *args)
      puts output

      status = 1 if Facter::Log.errors?
      exit status
    end

    desc 'help', 'Help for all arguments'
    def help(*args)
      help_string = +''
      help_string << help_header(args)
      help_string << add_class_options_to_help
      help_string << add_commands_to_help

      puts help_string
    end

    no_commands do
      def help_header(_args)
        path = File.join(File.dirname(__FILE__), '../../')

        Util::FileHelper.safe_read("#{path}fixtures/facter_help_header")
      end

      IGNORE_OPTIONS = %w[log_level color no_color].freeze

      def add_class_options_to_help
        help_class_options = +''
        class_options = Cli.class_options
        class_options.each do |class_option|
          option = class_option[1]
          next if option.hide

          help_class_options << build_option(option.name, option.aliases, option.description)
        end

        help_class_options
      end

      def add_commands_to_help
        help_command_options = +''
        Cli.commands
           .select { |_k, command_class| command_class.instance_of?(Thor::Command) }
           .each do |_k, command|
          help_command_options << build_option(command['name'], [], command['description'])
        end

        help_command_options
      end

      def build_option(name, aliases, description)
        help_option = +''
        help_option << aliases.join(',').rjust(10)
        help_option << ' '
        help_option << "[--#{name}]".ljust(30)
        help_option << " #{description}"
        help_option << "\n"

        help_option
      end
    end

    def self.exit_on_failure?
      true
    end

    default_task :query
  end
end
