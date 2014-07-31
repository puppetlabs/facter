Facter.add(:foo) do
    setcode 'echo bar 2>&1'
end

Facter.add(:foo) do
    setcode 'echo baz 2>&1'
end
