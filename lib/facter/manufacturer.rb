# manufacturer.rb
# Facts related to hardware manufacturer
#
#

require 'facter/util/manufacturer'
    
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
