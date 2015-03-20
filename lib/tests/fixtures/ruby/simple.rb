Facter.add(:foo) do
    setcode do
        'bar'
    end
end

Facter.add(:foo) do
    setcode do
        'baz'
    end
end
