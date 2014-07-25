Facter.add(:foo) do
    setcode do
        [1, true, false, 'foo', 12.4, [1], { :foo => 'bar' }]
    end
end
