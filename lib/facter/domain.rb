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

        Facter.value(:hostname)
        next $domain if defined? $domain and ! $domain.nil?

        domain = Facter::Util::Resolution.exec('dnsdomainname')
        next domain if domain =~ /.+\..+/

        if FileTest.exists?("/etc/resolv.conf")
            domain = nil
            search = nil
            File.open("/etc/resolv.conf") { |file|
                file.each { |line|
                    if line =~ /domain\s+(\S+)/
                        domain = $1
                    elsif line =~ /search\s+(\S+)/
                        search = $1
                    end
                }
            }
            next domain if domain
            next search if search
        end
        nil
    end
end

Facter.add(:domain) do
    confine :kernel => :windows
    setcode do
        require 'win32ole'
        domain = ""
        wmi = WIN32OLE.connect("winmgmts://")
        query = "select DNSDomain from Win32_NetworkAdapterConfiguration where IPEnabled = True"
        wmi.ExecQuery(query).each { |nic|
            domain = nic.DNSDomain
            break
        }
        domain
    end
end
