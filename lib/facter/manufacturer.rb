# Info about the manufacturer
#           
    
module Facter::Manufacturer
    def self.dmi_find_system_info(name)
        dmiinfo = `/usr/sbin/dmidecode`
        info = dmiinfo.scan(/^\s*System Information(.*?)\n\S/m).join.split("\n").map { |line|
            line.split(":").map { |line2| line2.strip }
        }.reject { |array| array.empty? }
        val = info.find { |array| array[0] == name}
        return (val && val.size >= 2) ? val[1] : nil
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
