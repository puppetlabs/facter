# A module to return config related data
#
module Facter::Util::Config
  require 'rbconfig'

  # Returns true if OS is windows
  def self.is_windows?
    Config::CONFIG['host_os'] =~ /mswin|win32|dos|mingw|cygwin/i
  end

  # Returns true if OS is Mac
  def self.is_mac?
    Config::CONFIG['host_os'] =~ /darwin/i
  end

  # Windows base data directory
  attr_accessor :windows_data_dir

  # The basedir to use for windows data
  def self.windows_data_dir
    if is_windows?
      # If neither environment variable is set - fail.
      if not ENV["ProgramData"] and not ENV["ALLUSERSPROFILE"] then
        raise "Neither environment variables ProgramData or ALLUSERSPROFILE " +
          "are defined. Facter is unable to determine a default dirctory for " +
          "its uses."
      end
      base_dir = ENV["ProgramData"] || 
        File.join(ENV["ALLUSERSPROFILE"], "Application Data") 
      File.join(base_dir, "Puppetlabs", "facter")
    else
      nil
    end
  end

  # Cache path attribute
  attr_accessor :cache_file

  # Retrieve the cache file path
  def self.cache_file
    if is_windows?
      @@cache_file ||= File.join(windows_data_dir, "cache/facter_cache.dat")
    elsif is_mac?
      @@cache_file ||= "/var/db/facter_cache.dat"
    else
      @@cache_file ||= "/var/cache/facter_cache.dat"
    end
    @@cache_file
  end

  # Set the current cache file path
  def self.cache_file=(path)
    @@cache_file = path
  end

  # External fact directory attribute
  attr_accessor :ext_fact_dir

  # Retrieve the external fact directory
  def self.ext_fact_dir
    if is_windows?
      @@ext_fact_dir ||= File.join(windows_data_dir, "facts.d")
    else
      @@ext_fact_dir ||= "/etc/facter/facts.d"
    end
    @@ext_fact_dir
  end

  # Set the external fact directory
  def self.ext_fact_dir=(path)
    @@ext_fact_dir = path
  end

end
