# Fact: macaddress
#
# Purpose: 
#
# Resolution:
#
# Caveats:
#

require 'facter/util/macaddress'

Facter.add(:macaddress) do
    confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS SuSE SLES Debian Gentoo Ubuntu OEL OVS GNU/kFreeBSD}
    setcode do
        ether = []
        output = %x{/sbin/ifconfig -a}
        output.each_line do |s|
            ether.push($1) if s =~ /(?:ether|HWaddr) (\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
        end
        ether[0]
    end
end

Facter.add(:macaddress) do
    confine :operatingsystem => "Solaris"
    setcode do
        ether = []
        output = Facter::Util::Resolution.exec("/usr/bin/netstat -np")
        output.each_line do |s|
            ether.push($1) if s =~ /(?:SPLA)\s+(\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2})/
        end
        ether[0]
    end
end

Facter.add(:macaddress) do
    confine :operatingsystem => %w{FreeBSD OpenBSD}
    setcode do
    ether = []
        output = %x{/sbin/ifconfig}
        output.each_line do |s|
            if s =~ /(?:ether|lladdr)\s+(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
                ether.push($1)
            end
        end
        ether[0]
    end
end

Facter.add(:macaddress) do
    confine :kernel => :darwin
    setcode { Facter::Util::Macaddress::Darwin.macaddress }
end

Facter.add(:macaddress) do
    confine :kernel => %w{AIX}
    setcode do
        ether = []
        ip = nil
        output = %x{/usr/sbin/ifconfig -a}
        output.each_line do |str|
            if str =~ /([a-z]+\d+): flags=/
                devname = $1
                unless devname =~ /lo0/
                    output2 = %x{/usr/bin/entstat #{devname}}
                    output2.each_line do |str2|
                        if str2 =~ /^Hardware Address: (\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
                            ether.push($1)
                        end
                    end
                end
            end
        end
        ether[0]
    end
end

Facter.add(:macaddress) do
    confine :kernel => %w(windows)
    setcode do
        require 'win32ole'
        require 'socket'

        ether = nil
        host = Socket.gethostname
        connect_string = "winmgmts://#{host}/root/cimv2"

        wmi = WIN32OLE.connect(connect_string)

        query = %Q{
          select *
          from Win32_NetworkAdapterConfiguration
          where IPEnabled = True
        }

        wmi.ExecQuery(query).each{ |nic|
          ether = nic.MacAddress
          break
        }
        
        ether
    end
end
