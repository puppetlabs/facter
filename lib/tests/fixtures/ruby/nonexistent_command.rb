Facter.add(:first) do
    setcode do
        next 'fail' unless Facter::Core::Execution.exec("does_not_exist || echo fail").nil?
        'pass'
    end
end

Facter.add(:second) do
    setcode 'does_not_exist || echo fail'
end

Facter.add(:third) do
    setcode do
        begin
            Facter::Core::Execution.execute("does_not_exist || echo fail")
        rescue Facter::Core::Execution::ExecutionFailure
            next 'pass'
        end
        'fail'
    end
end
