# Fact: domain
#
# Purpose:
#   Return the host's primary DNS domain name.
#
# Resolution:
#   On UNIX (excluding Darwin), first try and use the hostname fact,
#   which uses the hostname system command, and then parse the output
#   of that.
#   Failing that it tries the dnsdomainname system command.
#   Failing that it uses /etc/resolv.conf and takes the domain from that, or as
#   a final resort, the search from that.
#   Otherwise returns nil.
#
#   On Windows uses the win32ole gem and winmgmts to get the DNSDomain value
#   from the Win32 networking stack.
#
# Caveats:
#

Facter.add(:domain) do
  setcode do
    # Get the domain from various sources; the order of these
    # steps is important

    hostname_command = (Facter.value(:kernel) =~ /SunOS/i) ? 'hostname' : 'hostname -f' 
       
    if name = Facter::Util::Resolution.exec(hostname_command) \
      and name =~ /.*?\.(.+$)/

      $1
    elsif domain = Facter::Util::Resolution.exec('dnsdomainname') \
      and domain =~ /.+\..+/

      domain
    elsif FileTest.exists?("/etc/resolv.conf")
      domain = nil
      search = nil
      File.open("/etc/resolv.conf") { |file|
        file.each { |line|
          if line =~ /^\s*domain\s+(\S+)/
            domain = $1
          elsif line =~ /^\s*search\s+(\S+)/
            search = $1
          end
        }
      }
      next domain if domain
      next search if search
    end
  end
end

Facter.add(:domain) do
  confine :kernel => :windows
  setcode do
    require 'facter/util/registry'
    domain = ""
    regvalue = Facter::Util::Registry.hklm_read('SYSTEM\CurrentControlSet\Services\Tcpip\Parameters', 'Domain')
    domain = regvalue if regvalue
    if domain == ""
      require 'facter/util/wmi'
      Facter::Util::WMI.execquery("select DNSDomain from Win32_NetworkAdapterConfiguration where IPEnabled = True").each { |nic|
        domain = nic.DNSDomain
        break
      }
    end
    domain
  end
end
