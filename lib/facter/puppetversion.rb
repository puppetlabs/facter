Facter.add(:puppetversion) do
    setcode do
        begin
            require 'puppet'
            Puppet::PUPPETVERSION.to_s
        rescue LoadError
            nil
        end
    end
end
