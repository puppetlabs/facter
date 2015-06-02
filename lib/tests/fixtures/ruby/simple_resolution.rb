Facter.add(:foo, :type => :simple) do
    setcode do
        'bar'
    end
end
