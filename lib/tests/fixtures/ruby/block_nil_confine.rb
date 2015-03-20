Facter.add(:foo) do
    confine do
        nil
    end

    setcode do
        'bar'
    end
end
