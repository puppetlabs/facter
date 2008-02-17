## mamufacturer.rb
## Support methods for manufacturer specific facts
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


module Facter::Manufacturer
    def self.dmi_find_system_info(name)
        return nil unless FileTest.exists?("/usr/sbin/dmidecode")

        # Do not run the command more than every five seconds.
        unless defined?(@data) and defined?(@time) and (Time.now.to_i - @time.to_i < 5)
            @data = {}
            type = nil
            @time = Time.now
            # It's *much* easier to just parse the whole darn file than
            # to just match a chunk of it.
            %x{/usr/sbin/dmidecode 2>/dev/null}.split("\n").each do |line|
                case line
                when /^(\S.+)$/
                    type = $1.chomp
                    @data[type] ||= {}
                when /^\s+(\S.+): (\S.*)$/
                    unless type
                        next
                    end
                    @data[type][$1] = $2.strip
                end
            end
        end

        if data = @data["System Information"]
            data[name]
        else
            nil
        end
    end
end

