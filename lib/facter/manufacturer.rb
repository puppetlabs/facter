# Fact: manufacturer
#
# Purpose: Return the hardware manufacturer information about the hardware.
#
# Resolution:
#   On OpenBSD, queries `sysctl` values, via a util class.
#   On SunOS Sparc, uses `prtdiag` via a util class.
#   On Windows, queries the system via a util class.
#   Uses `util/manufacturer.rb` for fallback parsing.
#
# Caveats:
#

# manufacturer.rb
# Facts related to hardware manufacturer
#
#

require 'facter/util/manufacturer'

if Facter.value(:kernel) == "OpenBSD"
  mfg_keys = {
    'hw.vendor'   => 'manufacturer',
    'hw.product'  => 'productname',
    'hw.serialno' => 'serialnumber'
  }

  Facter::Manufacturer.sysctl_find_system_info(mfg_keys)
elsif Facter.value(:kernel) == "Darwin"
  mfg_keys = {
    'hw.model'   => 'productname'
  }
  Facter::Manufacturer.sysctl_find_system_info(mfg_keys)
elsif Facter.value(:kernel) == "SunOS" and Facter.value(:hardwareisa) == "sparc"
  Facter::Manufacturer.prtdiag_sparc_find_system_info()
elsif Facter.value(:kernel) == "windows"
  win32_keys = {
    'manufacturer' => ['Manufacturer', 'Bios'],
    'serialNumber' => ['Serialnumber', 'Bios'],
    'productname'  => ['Name', 'ComputerSystemProduct']
  }
  Facter::Manufacturer.win32_find_system_info(win32_keys)
else
  query = {
    '[Bb]ase [Bb]oard [Ii]nformation' => [
      { 'Manufacturer:'    => 'boardmanufacturer' },
      { 'Product(?: Name)?:' => 'boardproductname' },
      { 'Serial Number:'   => 'boardserialnumber' }
    ],
    '[Bb][Ii][Oo][Ss] [Ii]nformation' => [
      { '[Vv]endor:' => 'bios_vendor' },
      { '[Vv]ersion:' => 'bios_version' },
      { '[Rr]elease [Dd]ate:' => 'bios_release_date' }
    ],
    '[Ss]ystem [Ii]nformation' => [
      { 'Manufacturer:'    => 'manufacturer' },
      { 'Product(?: Name)?:' => 'productname' },
      { 'Serial Number:'   => 'serialnumber' },
      { 'UUID:'   => 'uuid' }
    ],
    '(Chassis Information|system enclosure or chassis)' => [
      { '(?:Chassis )?Type:' => 'type' }
    ]
  }

  Facter::Manufacturer.dmi_find_system_info(query)
end

