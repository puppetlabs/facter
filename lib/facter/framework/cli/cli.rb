#!/usr/bin/env ruby
# frozen_string_literal: true

module Facter
  class Cli < Thor
    check_unknown_options!

    class_option :color,
                 type: :boolean,
                 desc: 'Enable color output.'

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

    class_option :help,
                 hide: true,
                 aliases: '-h',
                 type: :boolean,
                 desc: 'Print this help message.'

    class_option :hocon,
                 type: :boolean,
                 desc: 'Output in Hocon format.'

    class_option :json,
                 aliases: '-j',
                 type: :boolean,
                 desc: 'Output in JSON format.'

    class_option :list_block_groups,
                 type: :boolean,
                 desc: 'List the names of all blockable fact groups.'

    class_option :list_cache_groups,
                 type: :boolean,
                 desc: 'List the names of all cacheable fact groups.'

    class_option :log_level,
                 aliases: '-l',
                 type: :string,
                 desc: 'Set logging level. Supported levels are: none, trace, debug, info, warn, error, and fatal.'

    class_option :block,
                 type: :boolean,
                 desc: 'Disable fact blocking.'

    class_option :cache,
                 type: :boolean,
                 desc: 'Disable loading and refreshing facts from the cache'

    class_option :custom_facts,
                 type: :boolean,
                 desc: 'Disable custom facts.'

    class_option :external_facts,
                 type: :boolean,
                 desc: 'Disable external facts.'

    class_option :ruby,
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

    class_option :puppet,
                 type: :boolean,
                 aliases: '-p',
                 desc: 'Load the Puppet libraries, thus allowing Facter to load Puppet-specific facts.'

    desc 'query', 'Default method', hide: true
    desc '[options] [query] [query] [...]', ''
    def query(*args)
      output, status = Facter.to_user_output(@options, *args)
      puts output

      status = 1 if Facter::Log.errors?
      exit status
    end

    desc '--version, -v', 'Print the version', hide: true
    map ['--version', '-v'] => :version
    def version
      puts FACTER_VERSION.to_s
    end

    desc '--list-block-groups', 'List block groups'
    map ['--list-block-groups'] => :list_block_groups
    def list_block_groups(*_args)
      puts Facter::FactGroups.new.groups.to_yaml.lines[1..-1].join
    end

    desc '--list-cache-groups', 'List cache groups'
    map ['--list-cache-groups'] => :list_cache_groups
    def list_cache_groups(*_args)
      puts Facter::FactGroups.new.groups.to_yaml.lines[1..-1].join
    end

    def self.exit_on_failure?
      true
    end

    default_task :query
  end
end
