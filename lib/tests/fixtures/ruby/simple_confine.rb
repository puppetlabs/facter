Facter.add(:foo) do
    confine 'SomeFact' => 'SomeValue'
    setcode do
        'bar'
    end
end
