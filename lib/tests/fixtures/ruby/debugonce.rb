Facter.add(:foo) do
    setcode do
        Facter.debugonce 'unique debug1'
        Facter.debugonce 'unique debug1'
        Facter.debugonce 'unique debug2'
        Facter.debugonce 'unique debug2'
        nil
    end
end
