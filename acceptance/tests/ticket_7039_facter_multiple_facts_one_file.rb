test_name "#7039: Facter having issue handling multiple facts in a single file"

fact_file= %q{
Facter.add(:test_fact1) do
    setcode do
        "test fact 1"
    end
end

Facter.add(:test_fact2) do
    setcode do
        "test fact 2"
    end
end
}

agent1=agents.first
step "Agent: Create fact file with multiple facts"
create_remote_file(agent1, '/tmp/test_facts.rb', fact_file )

step "Agent: Verify test_fact1 from /tmp/test_facts.rb"
on(agent1, "export FACTERLIB=/tmp && facter --puppet test_fact1") do
    fail_test "Fact 1 not returned by facter --puppet test_fact1" unless
      stdout.include? 'test fact 1'
end

step "Agent: Verify test_fact2 from /tmp/test_facts.rb"
on(agent1, "export FACTERLIB=/tmp && facter --puppet test_fact2") do
    fail_test "Fact 1 not returned by facter --puppet test_fact2" unless
      stdout.include? 'test fact 2'
end
