# mamufacturer.rb
# Support methods for manufacturer specific facts

module Facter::Manufacturer
	def self.dmi_find_system_info(name)
		case Facter.value(:kernel)
			when 'Linux'
				return nil unless FileTest.exists?("/usr/sbin/dmidecode")
		
				output=%x{/usr/sbin/dmidecode 2>/dev/null}
			when 'OpenBSD', 'FreeBSD'
				return nil unless FileTest.exists?("/usr/local/sbin/dmidecode")
		
				output=%x{/usr/local/sbin/dmidecode 2>/dev/null}
			when 'NetBSD'
				return nil unless FileTest.exists?("/usr/pkg/sbin/dmidecode")

				output=%x{/usr/pkg/sbin/dmidecode 2>/dev/null}
		end
		name.each_pair do |key,v|
			v.each do |value|
				output.split("Handle").each do |line|
					if line =~ /#{key}/  and line =~ /#{value} (\w.*)\n*./
						result = $1
						Facter.add(value.chomp(':').gsub(' ','')) do
							confine :kernel => [ :linux, :freebsd, :netbsd, :openbsd ]
							setcode do
							result
						end
					end
				end
			end
		end
	end
end
end

