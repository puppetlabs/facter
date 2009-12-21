Facter.add(:ipaddress) do
    confine :kernel => :linux
    setcode do
        ip = nil
        output = %x{/sbin/ifconfig}

        output.split(/^\S/).each { |str|
            if str =~ /inet addr:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
                tmp = $1
                unless tmp =~ /^127\./
                    ip = tmp
                    break
                end
            end
        }

        ip
    end
end

Facter.add(:ipaddress) do
    confine :kernel => %w{FreeBSD OpenBSD}
    setcode do
        ip = nil
        output = %x{/sbin/ifconfig}

        output.split(/^\S/).each { |str|
            if str =~ /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
                tmp = $1
                unless tmp =~ /^127\./
                    ip = tmp
                    break
                end
            end
        }

        ip
    end
end

Facter.add(:ipaddress) do
    confine :kernel => %w{NetBSD SunOS}
    setcode do
        ip = nil
        output = %x{/sbin/ifconfig -a}

        output.split(/^\S/).each { |str|
            if str =~ /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
                tmp = $1
                unless tmp =~ /^127\./
                    ip = tmp
                    break
                end
            end
        }

        ip
    end
end

Facter.add(:ipaddress) do
    confine :kernel => %w{darwin}
    setcode do
        ip = nil
        iface = ""
        output = %x{/usr/sbin/netstat -rn}
        if output =~ /^default\s*\S*\s*\S*\s*\S*\s*\S*\s*(\S*).*/
          iface = $1
        else
          warn "Could not find a default route. Using first non-loopback interface"
        end
        if(iface != "")
          output = %x{/sbin/ifconfig #{iface}}
        else
          output = %x{/sbin/ifconfig}
        end

        output.split(/^\S/).each { |str|
            if str =~ /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
                tmp = $1
                unless tmp =~ /^127\./
                    ip = tmp
                    break
                end
            end
        }

        ip
    end
end

Facter.add(:ipaddress) do
    confine :kernel => %w{AIX}
    setcode do
        ip = nil
        output = %x{/usr/sbin/ifconfig -a}

        output.split(/^\S/).each { |str|
            if str =~ /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
                tmp = $1
                unless tmp =~ /^127\./
                    ip = tmp
                    break
                end
            end
        }

        ip
    end
end

Facter.add(:ipaddress) do
    confine :kernel => %w{windows}
    setcode do
        ip = nil
        output = %x{ipconfig}

        output.split(/^\S/).each { |str|
            if str =~ /IP Address.*: ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
                tmp = $1
                unless tmp =~ /^127\./
                    ip = tmp
                    break
                end
            end
        }
        ip
    end
end

Facter.add(:ipaddress, :ldapname => "iphostnumber", :timeout => 2) do
    setcode do
        require 'resolv'

        begin
            if hostname = Facter.value(:hostname)
                ip = Resolv.getaddress(hostname)
                unless ip == "127.0.0.1"
                    ip
                end
            else
                nil
            end
        rescue Resolv::ResolvError
            nil
        rescue NoMethodError # i think this is a bug in resolv.rb?
            nil
        end
    end
end

Facter.add(:ipaddress, :timeout => 2) do
    setcode do
        if hostname = Facter.value(:hostname)
            # we need Hostname to exist for this to work
            host = nil
            if host = Facter::Util::Resolution.exec("host #{hostname}")
                list = host.chomp.split(/\s/)
                if defined? list[-1] and
                        list[-1] =~ /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/
                    list[-1]
                end
            else
                nil
            end
        else
            nil
        end
    end
end
