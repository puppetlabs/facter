Facter.add(:foo) do
    confine :fact => /foo/
    setcode do
        'bar'
    end
end
