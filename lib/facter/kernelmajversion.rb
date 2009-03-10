Facter.add("kernelmajversion") do
    setcode do
        Facter.value(:kernelversion).split('.')[0..1].join('.')
    end
end
