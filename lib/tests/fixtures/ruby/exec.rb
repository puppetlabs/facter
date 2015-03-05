Facter.add(:foo) do
    setcode do
        result = Facter::Core::Execution.exec('echo bar baz')
        raise 'nope' unless result == Facter::Util::Resolution.exec('echo bar baz')
        result
    end
end
