test_name "#7039: Facter having issue handling multiple facts in a single file"
confine :except, :platform => /^cisco-/

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

agents.each do |agent|
  step "Agent: Create fact file with multiple facts"
  dir = agent.tmpdir('facter7039')
  create_remote_file(agent, "#{dir}/test_facts.rb", fact_file)
  env = { 'FACTERLIB' => dir }

  step "Agent: Verify test_fact1 from #{dir}/test_facts.rb"
  on(agent, facter('test_fact1', :environment => env)) do
    fail_test "Fact 1 not returned by facter test_fact1" unless
      stdout.include? 'test fact 1'
  end

  step "Agent: Verify test_fact2 from #{dir}/test_facts.rb"
  on(agent, facter('test_fact2', :environment => env)) do
    fail_test "Fact 2 not returned by facter test_fact2" unless
      stdout.include? 'test fact 2'
  end
end
