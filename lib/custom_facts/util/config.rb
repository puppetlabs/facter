# frozen_string_literal: true

require 'rbconfig'

# A module to return config related data
#
module LegacyFacter
  module Util
    module Config
      def self.ext_fact_loader
        @ext_fact_loader || LegacyFacter::Util::DirectoryLoader.default_loader
      end

      def self.ext_fact_loader=(loader)
        @ext_fact_loader = loader
      end

      def self.mac?
        RbConfig::CONFIG['host_os'] =~ /darwin/i
      end

      # Returns true if OS is windows
      def self.windows?
        RbConfig::CONFIG['host_os'] =~ /mswin|win32|dos|mingw|cygwin/i
      end

      def self.windows_data_dir
        ENV['ProgramData'] || ENV['APPDATA'] if LegacyFacter::Util::Config.windows?
      end

      def self.external_facts_dirs
        Facter::Options.external_dir
      end

      def self.facts_cache_dir
        @facts_cache_dir ||= setup_default_cache_dir
      end

      def self.setup_default_ext_facts_dirs
        if LegacyFacter::Util::Root.root?
          windows_dir = windows_data_dir
          Facter::Options[:default_external_dir] = if windows_dir
                                                     [File.join(windows_dir, 'PuppetLabs', 'facter', 'facts.d')]
                                                   else
                                                     [
                                                       '/etc/puppetlabs/facter/facts.d',
                                                       '/etc/facter/facts.d/',
                                                       '/opt/puppetlabs/facter/facts.d'
                                                     ]
                                                   end
        elsif ENV['HOME']
          Facter::Options[:default_external_dir] =
            [File.join(ENV['HOME'], '.facter', 'facts.d'),
             File.join(ENV['HOME'], '.puppetlabs', 'opt', 'facter', 'facts.d')]
        else
          Facter::Options[:default_external_dir] = []
        end
      end

      if LegacyFacter::Util::Config.windows?
        require_relative 'windows_root'
      else
        require_relative 'unix_root'
      end

      setup_default_ext_facts_dirs

      def self.override_binary_dir=(dir)
        @override_binary_dir = dir
      end

      def self.override_binary_dir
        @override_binary_dir
      end

      def self.setup_default_cache_dir
        windows_dir = windows_data_dir
        @facts_cache_dir = if windows_dir
                             File.join(windows_dir, 'PuppetLabs', 'facter', 'cache', 'cached_facts')
                           else
                             '/opt/puppetlabs/facter/cache/cached_facts'
                           end
      end

      def self.setup_default_override_binary_dir
        @override_binary_dir = if LegacyFacter::Util::Config.windows?
                                 nil
                               else
                                 '/opt/puppetlabs/puppet/bin'
                               end
      end

      setup_default_override_binary_dir
    end
  end
end
