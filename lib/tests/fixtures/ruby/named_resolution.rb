Facter.add(:foo, :name => 'bar') do
    raise 'nope' unless name == 'bar'
    setcode do
        'value1'
    end
end

Facter.add(:foo, :name => 'bar') do
    raise 'nope' unless name == 'bar'
    setcode do
        'value2'
    end
end
