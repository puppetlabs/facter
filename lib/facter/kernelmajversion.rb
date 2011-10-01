# Fact: kernelmajversion
#
# Purpose: Return the operating system's release number's major value.
#
# Resolution:
#   Takes the first 2 elements of the kernel version as delimited by periods.
#
# Caveats:
#

Facter.add("kernelmajversion") do
  setcode do
    Facter.value(:kernelversion).split('.')[0..1].join('.')
  end
end
