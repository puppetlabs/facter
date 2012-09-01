# Fact: ipaddress
#
# Purpose: Return the main IP address for a host.
#
# Resolution:
#   On most operating systems it uses Facter::Util::IP, which will find an
#   appropriate binary and extract the first IP that matches the regexp/token/etc.
#
#   On LDAP based hosts it tries to use either the win32/resolv library to
#   resolve the hostname to an IP address, or on Unix, it uses the resolv
#   library.
#
#   As a fall back for undefined systems, it tries to run the "host" command to
#   resolve the machine's hostname using the system DNS.
#
# Caveats:
#   DNS resolution relies on working DNS infrastructure and resolvers on the
#   host system.
#   The ifconfig parsing purely takes the first IP address it finds without any
#   checking this is a useful IP address.
#

require 'facter/util/ip'

Facter.add(:ipaddress) do
  has_weight 100
  confine :kernel => %w{Linux FreeBSD OpenBSD Darwin DragonFly HP-UX GNU/kFreeBSD AIX windows}
  setcode do
    Facter::Util::IP.ipaddress(nil)
  end
end

Facter.add(:ipaddress) do
  has_weight 100
  confine :kernel => %w{NetBSD SunOS}
  setcode do
    Facter::Util::IP.ipaddress(nil, /^127\.|^0\.0\.0\.0/)
  end
end

Facter.add(:ipaddress, :ldapname => "iphostnumber", :timeout => 2) do
  setcode do
    if Facter.value(:kernel) == 'windows'
      require 'win32/resolv'
    else
      require 'resolv'
    end

    begin
      if hostname = Facter.value(:hostname)
        if Facter.value(:kernel) == 'windows'
          ip = Win32::Resolv.get_resolv_info.last[0]
        else
          ip = Resolv.getaddress(hostname)
        end
        unless ip == "127.0.0.1"
          ip
        end
      else
        nil
      end
    rescue Resolv::ResolvError
      nil
    rescue NoMethodError # i think this is a bug in resolv.rb?
      nil
    end
  end
end

Facter.add(:ipaddress, :timeout => 2) do
  setcode do
    if hostname = Facter.value(:hostname)
      # we need Hostname to exist for this to work
      host = nil
      if host = Facter::Util::Resolution.exec("host #{hostname}")
        list = host.chomp.split(/\s/)
        if defined? list[-1] and
          list[-1] =~ /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/
          list[-1]
        end
      else
        nil
      end
    else
      nil
    end
  end
end
