Facter.add(:foo) do
    setcode do
        Facter::Core::Execution.exec('echo bar && false')
    end
end
