#
# ipmess.rb
# Try to get additional Facts about the machine's network interfaces on Linux
#
# Original concept Copyright (C) 2007 psychedelys <psychedelys@gmail.com>
# Update and *BSD support (C) 2007 James Turnbull <james@lovedthanlost.net>
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation (version 2 of the License)
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston MA  02110-1301 USA
#

if Facter.kernel == "Linux"

       output = %x{/sbin/ifconfig -a}
       int = nil
        output.scan(/^(\w+)(\.|:?)(\d+)/) { |str|
         output_int = %x{/sbin/ifconfig #{str}}
         int = "#{str}"
         tmp1 = nil
         tmp2 = nil
         test = {}
          output_int.each { |s|
           int = "#{str}"
           tmp1 = $1 if s =~ /inet addr:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
           tmp2 = $1 if s =~ /(?:ether|HWaddr) (\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
           if tmp1 != nil && tmp2 != nil && int != "lo"
              test["ipaddress_" + int] = tmp1
              test["macaddress_" + int] = tmp2
              int = nil
              tmp1 = nil
              tmp2 = nil
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
       }
end

if Facter.kernel == "FreeBSD" || Facter.kernel == "OpenBSD" || Facter.kernel == "NetBSD"

       output = %x{/sbin/ifconfig -a}
        int = nil
        output.scan(/^(\w+)(\.|:?)(\d+):/) { |str|
         output_int = %x{/sbin/ifconfig #{str}}
         int = "#{str}"
         tmp1 = nil
         tmp2 = nil
         test = {}
          output_int.each { |s|
           int = "#{str}"
           tmp1 = $1 if s =~ /inet ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
           tmp2 = $1 if s =~ /(?:ether|lladdr)\s+(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
            if tmp1 != nil && tmp2 != nil && int != "lo"
              test["ipaddress_" + int] = tmp1
              test["macaddress_" + int] = tmp2
              int = nil
              tmp1 = nil
              tmp2 = nil
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
        }
end

