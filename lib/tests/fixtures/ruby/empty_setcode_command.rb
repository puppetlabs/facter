Facter.add(:foo) do
    setcode 'echo >&2'
end
