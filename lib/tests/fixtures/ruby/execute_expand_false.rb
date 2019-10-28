Facter.add(:foo) do
  setcode do
    Facter::Core::Execution.execute("cd /opt/puppetlabs && ls", {:expand => false})
  end
end
