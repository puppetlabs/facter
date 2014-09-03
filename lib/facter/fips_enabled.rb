# Fact: fips_enabled
#
# Purpose:
#   Determine whether FIPS is enabled on the node.
#
# Resolution:
#   Checks for /proc/sys/crypto/fips_enabled = 1
#
# Caveats:
#

# Fact for SElinux
# Written by Trevor Vaughan <tvaughan@onyxpoint.com>

Facter.add('fips_enabled') do
  confine :kernel => :linux
  setcode do
    result = 'false'
    begin
      if File.read('/proc/sys/crypto/fips_enabled').strip != '0'
        result = 'true'
      end
    rescue
    end
    result
  end
end
