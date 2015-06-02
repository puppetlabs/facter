Facter.define_fact(:foo) do
    raise 'nope' unless name == 'foo'

    define_resolution(nil, :type => :aggregate) do
        chunk :first do
            ['foo']
        end

        chunk :second do
            ['bar']
        end
    end
end
