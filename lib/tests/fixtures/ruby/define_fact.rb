Facter.define_fact(:foo) do
    raise 'nope' unless name == 'foo'

    define_resolution(nil) do
        setcode do
            'bar'
        end
    end
end
