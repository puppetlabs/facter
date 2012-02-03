require 'rbconfig'

# A module to return config related data
#
module Facter::Util::Config

  def self.is_mac?
    Config::CONFIG['host_os'] =~ /darwin/i
  end

  # Returns true if OS is windows
  def self.is_windows?
    RbConfig::CONFIG['host_os'] =~ /mswin|win32|dos|mingw|cygwin/i
  end

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

  # Retrieve the external fact directory
  def self.ext_fact_dir
    if is_windows?
      @@ext_fact_dir ||= File.join(windows_data_dir, "ext")
    else
      @@ext_fact_dir ||= "/usr/lib/facter/ext"
    end
    @@ext_fact_dir
  end

  # Set the external fact directory
  def self.ext_fact_dir=(path)
    @@ext_fact_dir = path
  end
end
