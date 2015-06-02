Facter.add(:foo) do
    confine :fact => (3..5)
    setcode do
        'bar'
    end
end
