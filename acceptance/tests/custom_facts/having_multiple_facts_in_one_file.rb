test_name 'C14893: Facter should handle multiple facts in a single file' do
  tag 'risk:high'

  fact_content = <<-EOM
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
  EOM

  agents.each do |agent|
    fact_dir = agent.tmpdir('facter')
    fact_file = File.join(fact_dir, 'test_facts.rb')
    create_remote_file(agent, fact_file, fact_content)
    env = {'FACTERLIB' => fact_dir}

    teardown do
      on(agent, "rm -rf '#{fact_dir}'")
    end

    step "Agent: Verify test_fact1 from #{fact_file}" do
      on(agent, facter('test_fact1', :environment => env)) do |facter_result|
        assert_equal('test fact 1', facter_result.stdout.chomp, 'test_fact1 is not the correct value')
      end
    end

    step "Agent: Verify test_fact2 from #{fact_file}" do
      on(agent, facter('test_fact2', :environment => env)) do |facter_result|
        assert_equal('test fact 2', facter_result.stdout.chomp, 'test_fact2 is not the correct value')
      end
    end
  end
end
