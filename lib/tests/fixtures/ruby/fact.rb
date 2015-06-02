Facter.add(:foo) do
    setcode do
        raise 'nope' unless Facter.fact('not_a_fact').nil?
        bar = Facter.fact('bar')
        bar.value unless bar.nil?
    end
end
