Facter.add('foo') do
    confine 'bar' => 'baz'
end

Facter.add('bar') do
    confine 'foo' => 'baz'
end
