Facter.add(:puppetversion, :timeout => 1.5) do
    setcode {
        begin
            require 'puppet'
            Puppet::PUPPETVERSION.to_s
        rescue LoadError
            nil
        end
    }
end
