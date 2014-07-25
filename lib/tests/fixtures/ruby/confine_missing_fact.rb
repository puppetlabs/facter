Facter.add(:foo) do
    confine :not_a_fact => 'foo'
    setcode do
        'bar'
    end
end

Facter.add(:foo) do
    confine :kernel => 'Linux', :not_a_fact => 'foo'
    setcode do
        'bar'
    end
end

Facter.add(:foo) do
    confine :not_a_fact do |value|
        true
    end
    setcode do
        'bar'
    end
end
