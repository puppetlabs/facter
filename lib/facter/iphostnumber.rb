Facter.add(:iphostnumber) do
    confine :kernel => :darwin, :kernelrelease => "R6"
    setcode do
        %x{/usr/sbin/scutil --get LocalHostName}
    end
end
Facter.add(:iphostnumber) do
    confine :kernel => :darwin, :kernelrelease => "R6"
    setcode do
        ether = nil
        output = %x{/sbin/ifconfig}

        output =~ /HWaddr (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
        ether = $1

        ether
    end
end
