# A module to return config related data
#
module Facter::Util::Config
  require 'rbconfig'

  CONF = Object.const_get(defined?(RbConfig) ? :RbConfig : :Config)::CONFIG

  def self.is_windows?
    CONF['host_os'] =~ /mswin|win32|dos|mingw|cygwin/i
  end
end
