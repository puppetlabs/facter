Facter.add(:ruby) do
    has_weight 1
    setcode do
        'override'
    end
end
