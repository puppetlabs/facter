Facter.add(:foo) do
    setcode do
        raise 'nope' unless Facter['not_a_fact'].nil?
        bar = Facter['bar']
        bar.value unless bar.nil?
    end
end
