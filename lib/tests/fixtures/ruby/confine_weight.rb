Facter.add(:foo) do
    confine :fact2 => 'value2'
    setcode do
        'value1'
    end
end

Facter.add(:foo) do
    confine :fact1 => 'value1', :fact2 => 'value2', :fact3 => 'value3'
    setcode do
        'value2'
    end
end

Facter.add(:foo) do
    confine :fact2 => 'value2', :fact3 => 'value3'
    setcode do
        'value3'
    end
end
