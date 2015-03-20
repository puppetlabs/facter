Facter.add(:foo) do
    confine 'Fact1' => 'Value1', 'Fact2' => 'Value2', 'Fact3' => 'Value3'
    setcode do
        'bar'
    end
end
