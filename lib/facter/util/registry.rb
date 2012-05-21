module Facter::Util::Registry
  class << self
    def hklm_read(key, value)
      require 'win32/registry'
      reg = Win32::Registry::HKEY_LOCAL_MACHINE.open(key)
      rval = reg[value]
      reg.close
      rval
    end
  end
end
