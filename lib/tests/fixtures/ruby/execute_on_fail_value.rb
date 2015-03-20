Facter.add(:foo) do
    setcode do
        Facter::Core::Execution.execute('not a command', :on_fail => 'default')
    end
end
