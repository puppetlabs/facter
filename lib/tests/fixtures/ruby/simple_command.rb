Facter.add(:foo) do
    setcode 'echo bar'
end

Facter.add(:foo) do
    setcode 'echo baz'
end
