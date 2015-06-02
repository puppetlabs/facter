# Should raise by default
begin
    Facter::Core::Execution.execute('not a command')
    raise 'did not raise'
rescue Facter::Core::Execution::ExecutionFailure
end

# Should raise if given an option hash that does not contain :on_fail
begin
    Facter::Core::Execution.execute('not a command', {})
    raise 'did not raise'
rescue Facter::Core::Execution::ExecutionFailure
end

# Should raise if directly given the option
Facter::Core::Execution.execute('not a command', :on_fail => :raise)
raise 'did not raise'
