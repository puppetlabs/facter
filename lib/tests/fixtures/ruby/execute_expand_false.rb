Facter.add(:foo) do
  setcode do
    Facter::Core::Execution.execute("cd /opt/puppetlabs && ls", {:expand => false}) unless Gem.win_platform?
  end
end
