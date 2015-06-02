Facter.add(:foo) do
    setcode do
        Facter.warnonce 'unique warning1'
        Facter.warnonce 'unique warning1'
        Facter.warnonce 'unique warning2'
        Facter.warnonce 'unique warning2'
        nil
    end
end
