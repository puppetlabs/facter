Facter.add(:foo) do
    confine :fact1 do |value|
        value == 'value1'
    end

    setcode do
        'bar'
    end
end
