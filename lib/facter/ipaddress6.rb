# Cody Herriges <c.a.herriges@gmail.com>
#
# Used the ipaddress fact that is already part of
# Facter as a template.

# OS dependant code that parses the output of various networking
# tools and currently not very intelligent. Returns the first
# non-loopback and non-linklocal address found in the ouput unless
# a default route can be mapped to a routeable interface. Guessing
# an interface is currently only possible with BSD type systems
# to many assumptions have to be made on other platforms to make
# this work with the current code. Most code ported or modeled
# after the ipaddress fact for the sake of similar functionality
# and familiar mechanics.
Facter.add(:ipaddress6) do
  confine :kernel => :linux
  setcode do
    ip = nil
    output = Facter::Util::Resolution.exec('/sbin/ifconfig')

    output.scan(/inet6 addr: ((?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/).each { |str|
      str = str.to_s
      unless str =~ /fe80.*/ or str == "::1"
        ip = str
      end
    }

    ip

  end
end

Facter.add(:ipaddress6) do
  confine :kernel => %w{SunOS}
  setcode do
    output = Facter::Util::Resolution.exec('/usr/sbin/ifconfig -a')
    ip = nil

    output.scan(/inet6 ((?>[0-9,a-f,A-F]*\:{0,2})+[0-9,a-f,A-F]{0,4})/).each { |str|
      str = str.to_s
      unless str =~ /fe80.*/ or str == "::1"
        ip = str
      end
    }

    ip

  end
end

Facter.add(:ipaddress6) do
  confine :kernel => %w{Darwin FreeBSD OpenBSD}
  setcode do
    output = Facter::Util::Resolution.exec('/sbin/ifconfig -a')
    ip = nil

    output.scan(/inet6 ((?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/).each do |str|
      str = str.to_s
      unless str =~ /fe80.*/ or str == "::1"
        ip = str
        break
      end
    end

    ip
  end
end

