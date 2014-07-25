Facter.add(:foo) do
    setcode do
        raise 'nope' unless Facter::Core::Execution.which('not_a_command').nil?
        raise 'nope' if Facter::Core::Execution.which('sh').nil? && Facter::Core::Execution.which('cmd.exe').nil?
        'bar'
    end
end
