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
  if Facter.value(:kernel) == 'HP-UX'
    if Facter.value(:architecture) == 'ia64'
      setcode do
        "ia64"
      end
    else
      setcode do
        "parisc"
      end
    end
  else
  setcode 'uname -p'
  end
end
