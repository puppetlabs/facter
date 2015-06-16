(1..100).each do
    Facter.add(:foo) do
        setcode do
            'bar'
        end
    end
end
