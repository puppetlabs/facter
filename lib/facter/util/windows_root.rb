require 'win32/security'

module Facter::Util::Root
  def self.root?
    Win32::Security.elevated_security?
  end
end
