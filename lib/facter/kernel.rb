# Fact: kernel
#
# Purpose: Returns the operating system's name.
#
# Resolution:
#   Uses Ruby's rbconfig to find host_os, if that is a Windows derivative, the
#   returns 'windows', otherwise returns "uname -s" verbatim.
#
# Caveats:
#

Facter.add(:kernel) do
    setcode do
        require 'rbconfig'
        case Config::CONFIG['host_os']
        when /mswin|win32|dos|cygwin|mingw/i
            'windows'
        else
            Facter::Util::Resolution.exec("uname -s")
        end
    end
end
