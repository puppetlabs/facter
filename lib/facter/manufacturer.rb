# manufacturer.rb
# Facts related to hardware manufacturer
#
#

require 'facter/util/manufacturer'

query = {
    '[Ss]ystem [Ii]nformation' => [
        { 'Manufacturer:'      => 'manufacturer' },
        { 'Product(?: Name)?:' => 'productname' },
        { 'Serial Number:'     => 'serialnumber' }
    ],
    '(Chassis Information|system enclosure or chassis)' => [
        { '(?:Chassis )?Type:' => 'type' }
    ]
}

Facter::Manufacturer.dmi_find_system_info(query)
