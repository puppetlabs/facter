Facter.add(:foo, :type => :aggregate) do
    chunk :first do
        ['foo']
    end

    chunk :second do
        ['bar']
    end
end
