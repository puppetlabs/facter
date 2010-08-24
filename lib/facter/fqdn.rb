Facter.add(:fqdn) do
    setcode do
        host = Facter.value(:hostname)
        domain = Facter.value(:domain)
        if host and domain
            [host, domain].join(".")
        else
            nil
        end
    end
end
