# Fact: fqdn
#
# Purpose: Returns the fully qualified domain name of the host.
#
# Resolution: Tries hostname -f if available or if not, it simply joins the
# hostname fact with the domain name fact.
#
# Caveats: On systems where hostname -f is supported, the behaviour is now
# similar to hostname -f, where it previously was similar to a concatenation
# of hostname||'.'||dnsdomainname. For other systems, the fqdn is still
# formed from said concatenation and no DNS resolution is performed.
#

Facter.add(:fqdn) do
  setcode do
    # Get the domain from various sources; the order of these
    # steps is important

    # In some OS 'hostname -f' will change the hostname to '-f'
    # On good OS, 'hostname -f' will return the FQDN which is preferable
    # See domain.rb for a longer explanation
    full_hostname = 'hostname -f 2> /dev/null'
    can_do_hostname_f = Regexp.union /Linux/i, /FreeBSD/i, /Darwin/i

    hostname_command = if Facter.value(:kernel) =~ can_do_hostname_f
                         full_hostname
                       else
                         nil
                       end

    if hostname_command \
      and name = Facter::Core::Execution.exec(hostname_command)

      return_value = name
    else
      host = Facter.value(:hostname)
      domain = Facter.value(:domain)
      if host and domain
        [host, domain].join(".")
      else
        nil
      end
    end
  end
end
