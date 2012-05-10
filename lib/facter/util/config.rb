# A module to return config related data.

require 'rbconfig'

module Facter::Util::Config
  def self.is_windows?
    RbConfig::CONFIG['host_os'] =~ /mswin|win32|dos|mingw|cygwin/i
  end
end
