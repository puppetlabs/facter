Facter.add(:foo) do
    setcode 'not_a_valid_command'
end

Facter.add(:foo) do
    setcode do
        Facter::Core::Execution.exec('not_a_valid_command')
    end
end

Facter.add(:foo) do
    setcode do
        begin
            Facter::Core::Execution.execute('not_a_valid_command')
            'bar'
        rescue Facter::Core::Execution::ExecutionFailure => ex
        end
    end
end
