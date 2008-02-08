## netmask.rb
## Find the netmask of the primary ipaddress
## Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
## Copyright (C) 2007 Mark 'phips' Phillips
##
## idea and originial source by Mark 'phips' Phillips
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

def get_netmask
	netmask = nil;
	ipregex = %r{(\d{1,3}\.){3}\d{1,3}}

	ops = nil
	case Facter.kernel 
		when 'Linux'
			ops = {
				:ifconfig => '/sbin/ifconfig',
				:regex => %r{\s+ inet\saddr: #{Facter.ipaddress} .*? Mask: (#{ipregex})}x,
				:munge => nil,
			}
		when 'SunOS'
			ops = {
				:ifconfig => '/usr/sbin/ifconfig -a',
				:regex => %r{\s+ inet\s+? #{Facter.ipaddress} \+? mask (\w{8})}x,
				:munge => Proc.new { |mask| mask.scan(/../).collect do |byte| byte.to_i(16) end.join('.') }
			}
	end

	%x{#{ops[:ifconfig]}}.split(/\n/).collect do |line|
		matches = line.match(ops[:regex])
		if !matches.nil?
			if ops[:munge].nil? 
				netmask = matches[1]
			else
				netmask = ops[:munge].call(matches[1])
			end
		end
	end
	netmask
end

Facter.add("netmask") do
	confine :kernel => [ :sunos, :linux ]
	setcode do
		get_netmask
	end
end

