# netmask.rb
# Find the netmask of the primary ipaddress
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# Copyright (C) 2007 Mark 'phips' Phillips
#
# idea and originial source by Mark 'phips' Phillips
#

def get_netmask
	netmask = nil;
	ipregex = %r{(\d{1,3}\.){3}\d{1,3}}

	ops = nil
	case Facter.value(:kernel) 
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

