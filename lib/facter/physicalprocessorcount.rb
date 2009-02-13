Facter.add("physicalprocessorcount") do
    confine :kernel => :linux

    setcode do
        ppcount = Facter::Util::Resolution.exec('grep "physical id" /proc/cpuinfo|cut -d: -f 2|sort -u|wc -l')
    end
end
