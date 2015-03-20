Facter.add(:foo) do
  setcode do
    { foo: 'bar' }
  end
end
