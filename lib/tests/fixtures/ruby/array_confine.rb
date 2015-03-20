Facter.add(:foo) do
    confine 'fact' => [ 'value1', 'value2', 'value3' ]
    setcode do
        'bar'
    end
end
