Facter.add(:foo) do
    setcode do
        raise 'nope' unless Facter.value('not_a_fact').nil?
        Facter.value('bar')
    end
end
