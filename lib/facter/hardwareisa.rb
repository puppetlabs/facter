# Fact: hardwareisa
#
# Purpose:
#   Returns hardware processor type.
#
# Resolution:
#   On Solaris, Linux and the BSDs simply uses the output of "uname -p"
#
# Caveats:
#   Some linuxes return unknown to uname -p with relative ease.
#

Facter.add(:hardwareisa) do
  setcode 'uname -p'
end
