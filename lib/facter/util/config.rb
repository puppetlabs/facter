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
    Config::CONFIG['host_os'] =~ /darwin/i
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

  def self.default_external_facts_dirs
    windows_dir = windows_data_dir
    if windows_dir.nil? then
      ["/etc/facter/facts.d", "/etc/puppetlabs/facter/facts.d"]
    else
      [File.join(windows_dir, 'PuppetLabs', 'facter', 'facts.d')]
    end
  end

  # This is a hack because we could not stub out the PATH_SEPARATOR constant
  # Evan, Sept/5/2012
  def self.path_sep
    File::PATH_SEPARATOR
  end


  def self.external_facts_dirs
    if ENV["FACTER_PATH"].nil? then
      default_external_facts_dirs
    else 
      ENV["FACTER_PATH"].split(path_sep)
    end
  end
end

if Facter::Util::Config.is_windows?
  require 'rubygems'
  require 'win32/dir'
end
