# Fact: kernelmajversion
#
# Purpose: Return the operating system's release number's major value.
#
# Resolution:
#   Takes the first two elements of the kernel version as delimited by periods.
#   Takes the first element of the kernel version on FreeBSD.
#
# Caveats:
#

Facter.add("kernelmajversion") do
  setcode do
    Facter.value(:kernelversion).split('.')[0..1].join('.')
  end
end

Facter.add("kernelmajversion") do
  confine :kernel => :FreeBSD
  setcode do
    Facter.value(:kernelversion).split('.')[0]
  end
end
