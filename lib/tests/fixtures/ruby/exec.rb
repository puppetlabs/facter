Facter.add(:foo) do
    setcode do
        result = Facter::Core::Execution.exec('echo bar')
        raise 'nope' unless result == Facter::Util::Resolution.exec('echo bar')
        result
    end
end
