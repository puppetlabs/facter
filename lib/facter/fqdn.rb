# Fact: fqdn
#
# Purpose: Returns the fully-qualified domain name of the host.
#
# Resolution: Simply joins the hostname fact with the domain name fact.
#
# Caveats: No attempt is made to check that the two facts are accurate or that
# the two facts go together. At no point is there any DNS resolution made
# either.
#

Facter.add(:fqdn) do
  setcode do
    host = Facter.value(:hostname)
    domain = Facter.value(:domain)
    if host and domain
      [host, domain].join(".")
    elsif host
      host
    else
      nil
    end
  end
end
