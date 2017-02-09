# Should raise by default
begin
    Facter::Core::Execution.execute('the_most_interesting_command_in_the_world')
    raise 'did not raise'
rescue Facter::Core::Execution::ExecutionFailure
end

# Should raise if given an option hash that does not contain :on_fail
begin
    Facter::Core::Execution.execute('the_most_interesting_command_in_the_world', {})
    raise 'did not raise'
rescue Facter::Core::Execution::ExecutionFailure
end

# Should raise if directly given the option
Facter::Core::Execution.execute('the_most_interesting_command_in_the_world', :on_fail => :raise)
raise 'did not raise'
