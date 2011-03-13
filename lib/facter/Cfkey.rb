# Fact: Cfkey
#
# Purpose: Return the public key(s) for CFengine.
#
# Resolution:
#   Tries each file of standard localhost.pub & cfkey.pub locations,
#   checks if they appear to be a public key, and then join them all together.
#
# Caveats:
#

## Cfkey.rb
## Facts related to cfengine
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

Facter.add(:Cfkey) do
    setcode do
        value = nil
        ["/usr/local/etc/cfkey.pub",
            "/etc/cfkey.pub",
            "/var/cfng/keys/localhost.pub",
            "/var/cfengine/ppkeys/localhost.pub",
            "/var/lib/cfengine/ppkeys/localhost.pub",
            "/var/lib/cfengine2/ppkeys/localhost.pub"
        ].each do |file|
            if FileTest.file?(file)
                File.open(file) { |openfile|
                    value = openfile.readlines.reject { |line|
                        line =~ /PUBLIC KEY/
                    }.collect { |line|
                        line.chomp
                    }.join("")
                }
            end
            if value
                break
            end
        end

        value
    end
end
