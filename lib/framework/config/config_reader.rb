# frozen_string_literal: true

module Facter
  class ConfigReader
    attr_accessor :conf

    def initialize(config_path = nil)
      @config_file_path = config_path || default_path
      refresh_config
    end

    def block_list
      @conf['facts'] && @conf['facts']['blocklist']
    end

    def ttls
      @conf['facts'] && @conf['facts']['ttls']
    end

    def global
      # puts @conf['global']
      @conf['global']
    end

    def cli
      @conf['cli']
    end

    def refresh_config
      @conf = File.exist?(@config_file_path) ? Hocon.load(@config_file_path) : {}
    end

    private

    def default_path
      os = OsDetector.instance.identifier

      windows_path = File.join('C:', 'ProgramData', 'PuppetLabs', 'facter', 'etc', 'facter.conf')
      linux_path = File.join('/', 'etc', 'puppetlabs', 'facter', 'facter.conf')

      os == :windows ? windows_path : linux_path
    end
  end
end
