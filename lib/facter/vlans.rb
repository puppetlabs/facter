require 'facter/util/vlans'
    
    Facter.add("vlans") do
        confine :kernel => :linux
        setcode do
            Facter::Util::Vlans.get_vlans
        end
    end
