Facter.add(:foo, :type => :aggregate) do
    chunk :first, :require => :second do |second|
        raise 'nope'
    end

    chunk :second, :require => :first do |first|
        raise 'nope'
    end
end
