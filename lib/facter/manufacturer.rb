# manufacturer.rb
# Facts related to hardware manufacturer
#
#

require 'facter/util/manufacturer'

query = { 'System Information' =>  [ 'Manufacturer:', 'Product Name:' , 'Serial Number:'], 'Chassis Information' => 'Type:'}

Facter::Manufacturer.dmi_find_system_info(query) 
