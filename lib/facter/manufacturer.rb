# Info about the manufacturer
#           
    
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
        
# Add the facts to Facter

{:SerialNumber => "Serial Number",
 :Manufacturer => "Manufacturer",
 :ProductName=> "Product Name"}.each do |fact, name|
    Facter.add(fact) do
        confine :kernel => :linux
        setcode do
            Facter::Manufacturer.dmi_find_system_info(name)
        end
    end  
end
