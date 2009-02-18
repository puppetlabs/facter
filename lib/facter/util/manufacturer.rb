# mamufacturer.rb
# Support methods for manufacturer specific facts

module Facter::Manufacturer
    def self.dmi_find_system_info(name)
        splitstr="Handle"
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
        when 'SunOS'
            return nil unless FileTest.exists?("/usr/sbin/smbios")
            splitstr="ID    SIZE TYPE"
            output=%x{/usr/sbin/smbios 2>/dev/null}

        else
            return
        end
        name.each_pair do |key,v|
            v.each do |v2|
                v2.each_pair do |value,facterkey|
                    output.split(splitstr).each do |line|
                        if line =~ /#{key}/ and ( line =~ /#{value} 0x\d+ \(([-\w].*)\)\n*./ or line =~ /#{value} ([-\w].*)\n*./ )
                            result = $1
                            Facter.add(facterkey) do
                                confine :kernel => [ :linux, :freebsd, :netbsd, :openbsd, :sunos ]
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
end
