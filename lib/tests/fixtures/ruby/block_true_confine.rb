Facter.add(:foo) do
    confine do
        true
    end

    setcode do
        'bar'
    end
end
