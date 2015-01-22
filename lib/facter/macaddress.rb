# Fact: macaddress
#
# Purpose:
#   Returns the MAC address of the primary network interface.
#
# Resolution:
#
# Caveats:
#

require 'facter/util/macaddress'
require 'facter/util/ip'

Facter.add(:macaddress) do
  confine :kernel => 'Linux'
  setcode do
    ether = []
    output = Facter::Util::IP.exec_ifconfig(["-a","2>/dev/null"])

    String(output).each_line do |s|
      ether.push($1) if s =~ /(?:ether|HWaddr) ((\w{1,2}:){5,}\w{1,2})/
    end
    Facter::Util::Macaddress.standardize(ether[0])
  end
end

Facter.add(:macaddress) do
  confine :kernel => %w{SunOS GNU/kFreeBSD}
  setcode do
    ether = []
    output = Facter::Util::IP.exec_ifconfig(["-a"])
    output.each_line do |s|
      ether.push($1) if s =~ /(?:ether|HWaddr) ((\w{1,2}:){5,}\w{1,2})/
    end
    Facter::Util::Macaddress.standardize(ether[0])
  end
end

Facter.add(:macaddress) do
  confine :osfamily => "Solaris"
  setcode do
    ether = []
    output = Facter::Core::Execution.exec("/usr/bin/netstat -np")
    output.each_line do |s|
      ether.push($1) if s =~ /(?:SPLA)\s+(\w{2}:\w{2}:\w{2}:\w{2}:\w{2}:\w{2})/
    end
    Facter::Util::Macaddress.standardize(ether[0])
  end
end

Facter.add(:macaddress) do
  confine :operatingsystem => %w{FreeBSD OpenBSD DragonFly}
  setcode do
    ether = []
    output = Facter::Util::IP.exec_ifconfig
    output.each_line do |s|
      if s =~ /(?:ether|lladdr)\s+(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
        ether.push($1)
      end
    end
    Facter::Util::Macaddress.standardize(ether[0])
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
    default_interface = Facter::Util::IP.exec_netstat(["-rn | grep default | awk '{ print $6 }'"])
    output = Facter::Util::IP.exec_ifconfig([default_interface])
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
    Facter::Util::Macaddress.standardize(ether[0])
  end
end

Facter.add(:macaddress) do
  confine :kernel => %w(windows)
  setcode do
    Facter::Util::Macaddress::Windows.macaddress
  end
end
