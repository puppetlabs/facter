# Fact: physicalprocessorcount
#
# Purpose: Return the number of physical processors.
#
# Resolution:
#   On linux, parses the output of '/proc/cpuinfo' for the number of unique
#   lines with "physical id" in them.
#
# Caveats:
#

Facter.add("physicalprocessorcount") do
    confine :kernel => :linux

    setcode do
        ppcount = Facter::Util::Resolution.exec('grep "physical id" /proc/cpuinfo|cut -d: -f 2|sort -u|wc -l')
    end
end
