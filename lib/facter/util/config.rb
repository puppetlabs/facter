# A module to return config related data
#
module Facter::Util::Config
  require 'rbconfig'

  def self.is_windows?
    Object.const_get(defined?(RbConfig) ? :RbConfig : :Config)::CONFIG['host_os'] =~ /mswin|win32|dos|mingw|cygwin/i
  end
end
