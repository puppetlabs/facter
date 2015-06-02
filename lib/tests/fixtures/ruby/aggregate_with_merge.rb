Facter.add(:foo, :type => :aggregate) do
    chunk :first do
        {
            'foo' => 'bar',
            'array' => [1, 2, 3],
            'hash' => {
                'jam' => 'cakes',
                'subarray' => ['hello']
            }
        }
    end

    chunk :second do
        {
            'baz' => 'jam',
            'array' => [4, 5, 6],
            'hash' => {
                'foo' => 'bar',
                'subarray' => ['world']
            }
        }
    end
end
