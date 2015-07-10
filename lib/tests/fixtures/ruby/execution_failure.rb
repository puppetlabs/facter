Facter.add(:foo) do
    setcode do
        Facter::Core::Execution.exec('echo | not_a_command 2>&1')
    end
end
