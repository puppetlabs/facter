#!/usr/bin/env ruby
# frozen_string_literal: true

module Facter
  class Cli < Thor
    class_option :color,
                 type: :boolean,
                 desc: 'Enable color output.'

    class_option :config,
                 aliases: :c,
                 type: :string,
                 desc: 'The location of the config file.'

    class_option :custom_dir,
                 type: :string,
                 desc: 'A directory to use for custom facts.'

    class_option :debug,
                 aliases: :d,
                 type: :boolean,
                 desc: 'Enable debug output.'

    class_option :external_dir,
                 type: :string,
                 desc: 'A directory to use for external facts.'

    class_option :help,
                 aliases: :h,
                 type: :boolean,
                 desc: 'Print this help message.'

    class_option :json,
                 aliases: :j,
                 type: :boolean,
                 desc: 'Output in JSON format.'

    class_option :list_block_groups,
                 type: :boolean,
                 desc: 'List the names of all blockable fact groups.'

    class_option :list_cache_groups,
                 type: :boolean,
                 desc: 'List the names of all cacheable fact groups.'

    class_option :log_level,
                 aliases: :l,
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
                 aliases: :y,
                 type: :boolean,
                 desc: 'Output in YAML format.'

    class_option :strict,
                 type: :boolean,
                 desc: 'Enable more aggressive error reporting.'

    # this is deprecated, maybe we should remove it
    class_option :puppet,
                 type: :boolean,
                 aliases: :p,
                 desc: '(Deprecated: use `puppet facts` instead) Load the Puppet libraries,
                         thus allowing Facter to load Puppet-specific facts.'

    desc 'query', 'query'
    def query(*args)
      puts Facter.to_hocon(*args)
    end

    desc '--version, -v', 'Print the version'
    map ['--version', '-v'] => :version
    def version
      puts FACTER_VERSION.to_s
    end

    default_task :query
  end
end
