Facter.add(:puppetversion) do
    setcode {
        begin
            require 'puppet'
            Puppet::PUPPETVERSION.to_s
        rescue LoadError
            nil
        end
    }
end
