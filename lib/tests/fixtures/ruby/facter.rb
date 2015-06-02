require 'facter'

Facter.add(:foo) do
  setcode do
    'bar'
  end
end