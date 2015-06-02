Facter.add(:foo, :weight => 100) do
    setcode do
        'value1'
    end
end

Facter.add(:foo, :weight => 1000) do
    setcode do
        'value2'
    end
end

Facter.add(:foo, :weight => 1) do
    setcode do
        'value3'
    end
end
