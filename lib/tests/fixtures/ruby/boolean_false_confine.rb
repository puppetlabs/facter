Facter.add(:foo) do
    confine 'fact' => false
    setcode do
        'bar'
    end
end
