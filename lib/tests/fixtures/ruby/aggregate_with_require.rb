Facter.add(:foo, :type => :aggregate) do
    chunk :first do
        ['foo']
    end

    chunk :second, :require => :first do |first|
        raise 'nope' unless first == ['foo']
        ['bar'] + first
    end

    chunk :third, :require => [:first, :second] do |first, second|
        raise 'nope' unless first == ['foo']
        raise 'nope' unless second == ['bar', 'foo']
        ['baz'] + first + second
    end
end
