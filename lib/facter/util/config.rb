require 'rbconfig'

# A module to return config related data
#
module Facter::Util::Config

  def self.ext_fact_loader
    @ext_fact_loader || Facter::Util::DirectoryLoader.default_loader
  end

  def self.ext_fact_loader=(loader)
    @ext_fact_loader = loader
  end

  def self.is_mac?
    RbConfig::CONFIG['host_os'] =~ /darwin/i
  end

  # Returns true if OS is windows
  def self.is_windows?
    RbConfig::CONFIG['host_os'] =~ /mswin|win32|dos|mingw|cygwin/i
  end

  def self.windows_data_dir
    if Dir.const_defined? 'COMMON_APPDATA' then
      Dir::COMMON_APPDATA
    else
      nil
    end
  end

  def self.external_facts_dirs=(dir)
    @external_facts_dirs = dir
  end

  def self.external_facts_dirs
    @external_facts_dirs
  end

  def self.setup_default_ext_facts_dirs
    if Facter::Util::Root.root?
      windows_dir = windows_data_dir
      if windows_dir.nil? then
        # Note: Beginning with Facter 3, /opt/puppetlabs/facter/facts.d will be the only
        # default external fact directory.
        @external_facts_dirs = ["/opt/puppetlabs/facter/facts.d",
                                "/etc/facter/facts.d",
                                "/etc/puppetlabs/facter/facts.d"]
      else
        @external_facts_dirs = [File.join(windows_dir, 'PuppetLabs', 'facter', 'facts.d')]
      end
    elsif ENV['HOME']
      # Note: Beginning with Facter 3, ~/.puppetlabs/opt/facter/facts.d will be the only
      # default external fact directory.
      @external_facts_dirs = [File.expand_path(File.join(ENV['HOME'], ".puppetlabs", "opt", "facter", "facts.d")),
                              File.expand_path(File.join(ENV['HOME'], ".facter", "facts.d"))]
    else
      @external_facts_dirs = []
    end
  end

  if Facter::Util::Config.is_windows?
    require 'win32/dir'
    require 'facter/util/windows_root'
  else
    require 'facter/util/unix_root'
  end

  setup_default_ext_facts_dirs

  def self.override_binary_dir=(dir)
    @override_binary_dir = dir
  end

  def self.override_binary_dir
    @override_binary_dir
  end

  def self.setup_default_override_binary_dir
    if Facter::Util::Config.is_windows?
      @override_binary_dir = nil
    else
      @override_binary_dir = "/opt/puppetlabs/puppet/bin"
    end
  end

  setup_default_override_binary_dir
end
