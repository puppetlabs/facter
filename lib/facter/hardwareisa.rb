# Fact: hardwareisa
#
# Purpose:
#   Returns hardware processor type.
#
# Resolution:
#   On Solaris, AIX, Linux and the BSDs simply uses the output of `uname -p`.
#   On HP-UX, `uname -m` gives us the same information.
#
# Caveats:
#   Some Linuxes return unknown to `uname -p` with relative ease.
#

Facter.add(:hardwareisa) do
  if Facter.value(:kernel) == 'HP-UX'
    setcode 'uname -m'
  else
    setcode 'uname -p'
  end
end
