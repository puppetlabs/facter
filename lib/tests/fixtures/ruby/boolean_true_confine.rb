Facter.add(:foo) do
    confine 'fact' => true
    setcode do
        'bar'
    end
end
