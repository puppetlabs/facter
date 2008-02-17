## ipmess.rb
## Try to get additional Facts about the machine's network interfaces on Linux
##
## Original concept Copyright (C) 2007 psychedelys <psychedelys@gmail.com>
## Update and *BSD support (C) 2007 James Turnbull <james@lovedthanlost.net>
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

require 'facter/kernel'

Facter.add(:interfaces) do
       confine :kernel => :sunos
       setcode do
        output = %x{/usr/sbin/ifconfig -a}
        int = nil
        int = output.scan(/(^\w+[.:]?\d+)/).join(" ")
       end
end

if Facter.value(:kernel) == "Linux"

       interfaces = nil
       interfaces = Facter.interfaces.split(" ")
       interfaces.each do |int|       
         output_int = %x{/sbin/ifconfig #{int}}
         tmp1 = nil
         tmp2 = nil
         tmp3 = nil
         test = {}
          output_int.each { |s|
           tmp1 = $1 if s =~ /inet addr:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
           tmp2 = $1 if s =~ /(?:ether|HWaddr)\s+(\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
           tmp3 = $1 if s =~ /Mask:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
           if tmp1 != nil && tmp2 != nil && tmp3 != nil && int != "lo"
              test["ipaddress_" + int] = tmp1
              test["macaddress_" + int] = tmp2
              test["netmask_" + int] = tmp3
              int = nil
              tmp1 = nil
              tmp2 = nil
              tmp3 = nil
           end
          }
        test.each{|name,fact|
                Facter.add(name) do
                      confine :kernel => :linux
                      setcode do
                            fact
                      end
                end
        }
       end
end

if Facter.value(:kernel) == "FreeBSD" || Facter.value(:kernel) == "OpenBSD" || Facter.value(:kernel) == "NetBSD"

       interfaces = nil
       interfaces = Facter.interfaces.split(" ")
       interfaces.each do |int|
         output_int = %x{/sbin/ifconfig #{int}}
         tmp1 = nil
         tmp2 = nil
         tmp3 = nil
         test = {}
          output_int.each { |s|
           tmp1 = $1 if s =~ /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
           tmp2 = $1 if s =~ /(?:ether|lladdr)\s+(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
           tmp3 = $1 if s =~ /netmask\s+(\w{10})/
            if tmp1 != nil && tmp2 != nil && tmp3 != nil && int != "lo"
              test["ipaddress_" + int] = tmp1
              test["macaddress_" + int] = tmp2
              test["netmask_" + int] = tmp3
              int = nil
              tmp1 = nil
              tmp2 = nil
              tmp3 = nil
            end
           } 
           test.each{|name,fact|
                Facter.add(name) do
                      confine :kernel => [ :freebsd, :openbsd, :netbsd ]
                      setcode do
                            fact
                      end
                end
           }
        end
end

if Facter.value(:kernel) == "SunOS"

       interfaces = nil
       interfaces = Facter.interfaces.split(" ")
       interfaces.each do |int|
         output_int = %x{/usr/sbin/ifconfig #{int}}
         tmp1 = nil
         tmp2 = nil
         tmp3 = nil
         test = {}
          output_int.each { |s|
           tmp1 = $1 if s =~ /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
           tmp2 = $1 if s =~ /(?:ether|lladdr)\s+(\w?\w:\w?\w:\w?\w:\w?\w:\w?\w:\w?\w)/
           tmp3 = $1 if s =~ /netmask\s+(\w{8})/
            if tmp1 != nil && tmp2 != nil && tmp3 != nil && int != "lo"
              test["ipaddress_" + int] = tmp1
              test["macaddress_" + int] = tmp2
              test["netmask_" + int] = tmp3
              int = nil
              tmp1 = nil
              tmp2 = nil
              tmp3 = nil
            end
           }
           test.each{|name,fact|
                Facter.add(name) do
                      confine :kernel => [ :sunos ]
                      setcode do
                            fact
                      end
                end
           }
        end
end
