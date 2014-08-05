Facter.add(:foo, :type => :aggregate) do
    chunk :first do
        ['foo']
    end

    chunk :second, :require => ['first'] do |first|
        raise 'nope'
    end
end
