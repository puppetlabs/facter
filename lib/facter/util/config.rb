# Module: Config
#
# Purpose: Returns config related data.
#
# Resolution:
#
# Caveats:
#
module Facter::Util::Config
  require 'rbconfig'

  def self.is_windows?
    Config::CONFIG['host_os'] =~ /mswin|win32|dos|mingw|cygwin/i
  end
end
