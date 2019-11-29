Facter.add(:zoo) do
  setcode do
    Facter::Core::Execution.execute("cd /opt/puppetlabs && ls", {:expand => true})
  end
end
