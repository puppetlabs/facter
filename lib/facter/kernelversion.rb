# Fact: kernelversion
#
# Purpose: Return the operating system's kernel version.
#
# Resolution:
#   On Solaris and SunOS based machines, returns the output of `uname -v`.
#   Otherwise returns the kernerlversion fact up to the first `-`. This may be
#   the entire kernelversion fact in many cases.
#
# Caveats:
#

Facter.add("kernelversion") do
  setcode do
    Facter['kernelrelease'].value.split('-')[0]
  end
end

Facter.add("kernelversion") do
  confine :kernel => :sunos
  setcode 'uname -v'
end
