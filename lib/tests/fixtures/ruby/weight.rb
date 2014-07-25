Facter.add(:foo) do
    has_weight 100
    setcode do
        'value1'
    end
end

Facter.add(:foo) do
    has_weight 1000
    setcode do
        'value2'
    end
end

Facter.add(:foo) do
    has_weight 1
    setcode do
        'value3'
    end
end
