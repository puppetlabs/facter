     Facter.add(:domain) do
            setcode do
                # First force the hostname to be checked
                Facter.value(:hostname)

                # Now check to see if it set the domain
                if defined? $domain and ! $domain.nil?
                    $domain
                else
                    nil
                end
            end
        end
        # Look for the DNS domain name command first.
        Facter.add(:domain) do
            setcode do
                domain = Facter::Util::Resolution.exec('dnsdomainname') or nil
                # make sure it's a real domain
                if domain and domain =~ /.+\..+/
                    domain
                else
                    nil
                end
            end
        end
        Facter.add(:domain) do
            setcode do
                domain = Facter::Util::Resolution.exec('domainname') or nil
                # make sure it's a real domain
                if domain and domain =~ /.+\..+/
                    domain
                else
                    nil
                end
            end
        end
        Facter.add(:domain) do
            setcode do
                value = nil
                if FileTest.exists?("/etc/resolv.conf")
                    File.open("/etc/resolv.conf") { |file|
                        # is the domain set?
                        file.each { |line|
                            if line =~ /domain\s+(\S+)/
                                value = $1
                                break
                            end
                        }
                    }
                    ! value and File.open("/etc/resolv.conf") { |file|
                        # is the search path set?
                        file.each { |line|
                            if line =~ /search\s+(\S+)/
                                value = $1
                                break
                            end
                        }
                    }
                    value
                else
                    nil
                end
            end
        end
