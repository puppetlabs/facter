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

Facter.add(:ipaddress) do
  confine :kernel => :linux
  setcode do
    ip = nil
    output = %x{/sbin/ifconfig}

    output.split(/^\S/).each { |str|
      if str =~ /inet addr:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
        tmp = $1
        unless tmp =~ /^127\./
          ip = tmp
          break
        end
      end
    }

    ip
  end
end

Facter.add(:ipaddress) do
  confine :kernel => %w{FreeBSD OpenBSD Darwin DragonFly}
  setcode do
    ip = nil
    output = %x{/sbin/ifconfig}

    output.split(/^\S/).each { |str|
      if str =~ /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
        tmp = $1
        unless tmp =~ /^127\./
          ip = tmp
          break
        end
      end
    }

    ip
  end
end

Facter.add(:ipaddress) do
  confine :kernel => %w{NetBSD SunOS}
  setcode do
    ip = nil
    output = %x{/sbin/ifconfig -a}

    output.split(/^\S/).each { |str|
      if str =~ /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
        tmp = $1
        unless tmp =~ /^127\./ or tmp == "0.0.0.0"
          ip = tmp
          break
        end
      end
    }

    ip
  end
end

Facter.add(:ipaddress) do
  confine :kernel => %w{AIX}
  setcode do
    ip = nil
    output = %x{/usr/sbin/ifconfig -a}

    output.split(/^\S/).each { |str|
      if str =~ /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
        tmp = $1
        unless tmp =~ /^127\./
          ip = tmp
          break
        end
      end
    }

    ip
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
