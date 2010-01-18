Facter.add(:fqdn) do
    setcode do
        # try to fetch the fqdn from hostname if long hostname is used.
        Facter.value(:hostname)
        next $fqdn if defined? $fqdn and ! $fqdn.nil?

        host = Facter.value(:hostname)
        domain = Facter.value(:domain)
        if host and domain
            [host, domain].join(".")
        else
            nil
        end
    end
end
