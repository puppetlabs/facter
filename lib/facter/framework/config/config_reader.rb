# frozen_string_literal: true

module Facter
  class ConfigReader
    class << self
      attr_accessor :conf

      def init(config_path = nil)
        config_path ||= default_path
        refresh_config(config_path)
        self
      end

      def block_list
        @conf['facts'] && @conf['facts']['blocklist']
      end

      def ttls
        @conf['facts'] && @conf['facts']['ttls']
      end

      def global
        @conf['global']
      end

      def cli
        @conf['cli']
      end

      def fact_groups
        @conf['fact-groups']
      end

      def refresh_config(config_path)
        @conf = File.readable?(config_path) ? Hocon.load(config_path) : {}
      rescue StandardError => e
        log.warn("Facter failed to read config file #{config_path} with the following error: #{e.message}")
        @conf = {}
      end

      private

      def log
        @log ||= Log.new(self)
      end

      def default_path
        os = OsDetector.instance.identifier

        windows_path = File.join('C:', 'ProgramData', 'PuppetLabs', 'facter', 'etc', 'facter.conf')
        linux_path = File.join('/', 'etc', 'puppetlabs', 'facter', 'facter.conf')

        os == :windows ? windows_path : linux_path
      end
    end
  end
end
