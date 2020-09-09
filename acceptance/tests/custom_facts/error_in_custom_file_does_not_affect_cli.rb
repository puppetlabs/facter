test_name 'Facter cli works when there is an error inside a custom fact file' do
  tag 'risk:high'

  first_file_content = <<-EOM
    Facter.add(:custom_fact_1) do
      setcode do
        'custom_fact_1_value'
      end
    end
     
    # some error
    nill.size
     
    Facter.add(:custom_fact_2) do
      setcode do
        'custom_fact_2_value'
      end
    end
     
    Facter.add(:custom_fact_3) do
      setcode do
        'custom_fact_3_value'
      end
    end
  EOM

  second_file_content = <<~EOM
    Facter.add(:custom_fact_4) do
      setcode do
        'custom_fact_4_value'
      end
    end
  EOM

  def create_custom_fact_file(file_name, file_content, fact_dir, agent)
    fact_file = File.join(fact_dir, file_name)
    create_remote_file(agent, fact_file, file_content)
  end

  agents.each do |agent|
    custom_facts = agent.tmpdir('custom_facts_dir')

    os_name = on(agent, facter('os.name')).stdout.chomp

    create_custom_fact_file('file1.rb', first_file_content, custom_facts, agent)
    create_custom_fact_file('file2.rb', second_file_content, custom_facts, agent)
    env = {'FACTERLIB' => custom_facts}

    teardown do
      agent.rm_rf(custom_facts)
    end

    step "Agent #{agent}: Verify that custom fact 1 is available" do
      on(agent, facter('custom_fact_1', environment: env), acceptable_exit_codes: [1]) do |facter_output|
        assert_equal('custom_fact_1_value', facter_output.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that custom fact 2 is not available" do
      on(agent, facter('custom_fact_2', environment: env), acceptable_exit_codes: [1]) do |facter_output|
        assert_equal('', facter_output.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that custom fact 3 is not available" do
      on(agent, facter('custom_fact_3', environment: env), acceptable_exit_codes: [1]) do |facter_output|
        assert_equal('', facter_output.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that custom fact 4 is available" do
      on(agent, facter('custom_fact_4', environment: env), acceptable_exit_codes: [1]) do |facter_output|
        assert_equal('custom_fact_4_value', facter_output.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that a core fact is still available" do
      on(agent, facter('os.name', environment: env), acceptable_exit_codes: [1]) do |facter_output|
        assert_equal(os_name, facter_output.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that an error is outputted when custom fact file has an error" do
      on(agent, facter('custom_fact_4', environment: env), acceptable_exit_codes: [1]) do |facter_output|
        assert_match(/ERROR Facter - error while resolving custom facts in .*file1.rb undefined local variable or method `nill'/,
          facter_output.stderr.chomp)
      end
    end

    step "Agent #{agent}: Verify that most core facts are available" do
      on(agent, facter('--json')) do |facter_output|
        expected_keys = %w[identity memory os ruby networking system_uptime processors]
        actual_keys = JSON.parse(facter_output.stdout).keys

        assert_equal(true, (expected_keys - actual_keys).empty?)
      end
    end
  end
end

