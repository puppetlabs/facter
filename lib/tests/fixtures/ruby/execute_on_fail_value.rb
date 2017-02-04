Facter.add(:foo) do
    setcode do
        Facter::Core::Execution.execute('the_most_interesting_command_in_the_world', :on_fail => 'default')
    end
end
