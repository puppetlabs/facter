# Fact: ipaddress
#
# Purpose: Return the main IP address for a host.
#
# Resolution:
#   On the Unixes does an ifconfig, and returns the first non 127.0.0.0/8
#   subnetted IP it finds.
#   On Windows, it attempts to use the socket library and resolve the machine's
#   hostname via DNS.
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

def get_address_after_token(output, token, return_first=false, ignore=/^127\./)
  ip = nil

  output.scan(/#{token}([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/).each do |match|
    match = match.first
    unless match =~ ignore
      ip = match
      break if return_first
    end
  end

  ip
end

Facter.add(:ipaddress) do
  has_weight 100
  confine :kernel => :linux
  setcode do
    ip = nil
    if FileTest.exists? '/sbin/ifconfig'
      output = Facter::Util::Resolution.exec('/sbin/ifconfig')
      get_address_after_token(output, 'inet addr:')
    else
      nil
    end
  end
end

Facter.add(:ipaddress) do
  has_weight 50
  confine :kernel => :linux
  setcode do
    ip = nil
    if FileTest.exists? '/sbin/ip'
      output = Facter::Util::Resolution.exec('/sbin/ip addr show')
      get_address_after_token(output, 'inet ')
    else
      nil
    end
  end
end

Facter.add(:ipaddress) do
  has_weight 100
  confine :kernel => %w{FreeBSD OpenBSD Darwin DragonFly}
  setcode do
    ip = nil
    if FileTest.exists? '/sbin/ifconfig'
      output = Facter::Util::Resolution.exec('/sbin/ifconfig')
      get_address_after_token(output, 'inet ', true)
    else
      nil
    end
  end
end

Facter.add(:ipaddress) do
  has_weight 100
  confine :kernel => %w{NetBSD SunOS}
  setcode do
    ip = nil
    if FileTest.exists? '/sbin/ifconfig'
      output = Facter::Util::Resolution.exec('/sbin/ifconfig')
      get_address_after_token(output, 'inet addr:', false, /^127\.|^0\.0\.0\.0/)
    else
      nil
    end
  end
end

Facter.add(:ipaddress) do
  confine :kernel => %w{AIX}
  setcode do
    ip = nil
    if FileTest.exists? '/sbin/ifconfig'
      output = Facter::Util::Resolution.exec('/sbin/ifconfig -a')
      get_address_after_token(output, 'inet ')
    else
      nil
    end
  end
end

Facter.add(:ipaddress) do
  confine :kernel => %w{windows}
  setcode do
    require 'socket'
    IPSocket.getaddress(Socket.gethostname)
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
