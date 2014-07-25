Facter.add(:foo) do
    confine do
        false
    end

    setcode do
        'bar'
    end
end
