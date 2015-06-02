Facter.add(:foo) do
    setcode 'echo bar baz'
end

Facter.add(:foo) do
    setcode 'echo baz'
end
