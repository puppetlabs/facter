## lsb.rb
## Facts related to Linux Standard Base (LSB)
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

{  "LSBRelease"         => %r{^LSB Version:\t(.*)$},
   "LSBDistId"          => %r{^Distributor ID:\t(.*)$},
   "LSBDistRelease"     => %r{^Release:\t(.*)$},
   "LSBDistDescription" => %r{^Description:\t(.*)$},
   "LSBDistCodeName"    => %r{^Codename:\t(.*)$}
}.each do |fact, pattern|
    Facter.add(fact) do
        confine :kernel => :linux
        setcode do
            unless defined?(@@lsbdata) and defined?(@@lsbtime) and (Time.now.to_i - @@lsbtime.to_i < 5)
                type = nil
                @@lsbtime = Time.now
                @@lsbdata = Facter::Util::Resolution.exec('lsb_release -a 2>/dev/null')
            end

            if pattern.match(@@lsbdata)
                $1
            else
                nil
            end
        end
    end
end
