## networking.rb
## Facts related to networking
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation (version 2 of the License)
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston MA  02110-1301 USA
##

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
        Facter.add(:hostname, :ldapname => "cn") do
            setcode do
                hostname = nil
                name = Facter::Util::Resolution.exec('hostname') or nil
                if name
                    if name =~ /^([\w-]+)\.(.+)$/
                        hostname = $1
                        # the Domain class uses this
                        $domain = $2
                    else
                        hostname = name
                    end
                    hostname
                else
                    nil
                end
            end
        end

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

        Facter.add(:ipaddress, :ldapname => "iphostnumber") do
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
        Facter.add(:ipaddress) do
            setcode do
                if hostname = Facter.value(:hostname)
                    # we need Hostname to exist for this to work
                    host = nil
                    if host = Facter::Util::Resolution.exec("host #{hostname}")
                        host = host.chomp.split(/\s/)
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

        Facter.add(:uniqueid) do
            setcode 'hostid',  '/bin/sh'
            confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS SuSE Debian Gentoo}
        end

        Facter.add(:macaddress) do
            confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS SuSE Debian Gentoo}
            setcode do
                ether = []
                output = %x{/sbin/ifconfig -a}
                output.each {|s|
                             ether.push($1) if s =~ /(?:ether|HWaddr) (\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
                            }
                ether[0]
            end
        end

        Facter.add(:macaddress) do
            confine :operatingsystem => %w{FreeBSD OpenBSD}
            setcode do
            ether = []
                output = %x{/sbin/ifconfig}
                output.each {|s|
                             if s =~ /(?:ether|lladdr)\s+(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
                                  ether.push($1)
                             end
                            }
                ether[0]
            end
        end

        Facter.add(:macaddress) do
            confine :kernel => :darwin
            setcode do
                ether = nil
                output = %x{/sbin/ifconfig}

                output.split(/^\S/).each { |str|
                    if str =~ /10baseT/ # we're wired
                        str =~ /ether (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
                        ether = $1
                    end
                }

                ether
            end
        end

         Facter.add(:ipaddress) do
            confine :kernel => :linux
            setcode do
                ip = nil
                output = %x{/sbin/ifconfig}

                output.split(/^\S/).each { |str|
                    if str =~ /inet addr:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
                        tmp = $1
                        unless tmp =~ /127\./
                            ip = tmp
                            break
                        end
                    end
                }

                ip
            end
        end
        Facter.add(:ipaddress) do
            confine :kernel => %w{FreeBSD OpenBSD solaris}
            setcode do
                ip = nil
                output = %x{/sbin/ifconfig}

                output.split(/^\S/).each { |str|
                    if str =~ /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
                        tmp = $1
                        unless tmp =~ /127\./
                            ip = tmp
                            break
                        end
                    end
                }

                ip
            end
        end
        Facter.add(:ipaddress) do
            confine :kernel => %w{NetBSD}
            setcode do
                ip = nil
                output = %x{/sbin/ifconfig -a}

                output.split(/^\S/).each { |str|
                    if str =~ /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
                        tmp = $1
                        unless tmp =~ /127\./
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
                        unless tmp =~ /127\./
                            ip = tmp
                            break
                        end
                    end
                }

                ip
            end
        end
        Facter.add(:hostname) do
            confine :kernel => :darwin, :kernelrelease => "R7"
            setcode do
                %x{/usr/sbin/scutil --get LocalHostName}
            end
        end
        Facter.add(:iphostnumber) do
            confine :kernel => :darwin, :kernelrelease => "R6"
            setcode do
                %x{/usr/sbin/scutil --get LocalHostName}
            end
        end
        Facter.add(:iphostnumber) do
            confine :kernel => :darwin, :kernelrelease => "R6"
            setcode do
                ether = nil
                output = %x{/sbin/ifconfig}

                output =~ /HWaddr (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
                ether = $1

                ether
            end
        end

