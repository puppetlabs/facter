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
