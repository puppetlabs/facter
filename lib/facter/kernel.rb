Facter.add(:kernel) do
    setcode 'uname -s'
end
