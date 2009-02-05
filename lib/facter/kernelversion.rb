Facter.add("kernelversion") do
    setcode do
        Facter['kernelrelease'].value.split('-')[0]
    end
end

Facter.add("kernelversion") do
    confine :kernel => :sunos
    setcode 'uname -v'
end
