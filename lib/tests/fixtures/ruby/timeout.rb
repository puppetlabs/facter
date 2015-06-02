# We should get a warning for using the timeout option
Facter.add(:timeout, :name => 'bar', :timeout => 1000) do
    # And another warning for using timeout=
    self.timeout = 10
end

# Try again to ensure only one warning each
Facter.add(:timeout, :name => 'bar', :timeout => 100) do
    self.timeout = 1
end
