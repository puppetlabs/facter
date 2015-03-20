Facter.add(:foo, :type => :aggregate) do
    chunk :first do
        {
            'foo' => 'hello',
        }
    end

    chunk :second do
        {
            'foo' => 'world'
        }
    end
end
