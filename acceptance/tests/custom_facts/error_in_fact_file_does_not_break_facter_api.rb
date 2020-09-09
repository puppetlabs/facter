test_name 'Facter api works when there is an error inside a custom fact file' do
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

  def create_custom_fact_file(file_name, file_content, test_vars)
    fact_file = File.join(test_vars[:fact_dir], file_name)
    create_remote_file(test_vars[:agent], fact_file, file_content)
  end

  def create_api_call_file(test_vars, facter_querry)
    file_content = <<-EOM
      #!/usr/bin/env ruby
      require 'facter'
      Facter.search(\'#{test_vars[:fact_dir]}\')
puts Facter.to_hash
      #{facter_querry}
    EOM
    create_custom_fact_file(test_vars[:fact_query_file_name], file_content, test_vars)
  end

  agents.each do |agent|
    test_vars = {}
    test_vars[:fact_dir] = agent.tmpdir('custom_facts')
    test_vars[:agent] = agent
    test_vars[:fact_query_file_name] = 'file3.rb'
    test_vars[:fact_query_file_path] = File.join(test_vars[:fact_dir], test_vars[:fact_query_file_name])

    create_custom_fact_file('file1.rb', first_file_content, test_vars)
    create_custom_fact_file('file2.rb', second_file_content, test_vars)

    teardown do
      agent.rm_rf(test_vars[:fact_dir])
    end

    step "Agent #{agent}: Verify that custom fact 1 is available" do
      create_api_call_file(test_vars, "puts Facter.value('custom_fact_1')")
      on(agent, "#{ruby_command(agent)} #{test_vars[:fact_query_file_path]}") do |ruby_result|
        assert_match(/custom_fact_1_value/, ruby_result.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that custom fact 2 is missing" do
      create_api_call_file(test_vars, "puts Facter.value('custom_fact_2')")
      on(agent, "#{ruby_command(agent)} #{test_vars[:fact_query_file_path]}") do |ruby_result|
        assert_no_match(/custom_fact_2_value/, ruby_result.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that custom fact 3 is missing" do
      create_api_call_file(test_vars, "puts Facter.value('custom_fact_3')")
      on(agent, "#{ruby_command(agent)} #{test_vars[:fact_query_file_path]}") do |ruby_result|
        assert_no_match(/custom_fact_3_value/, ruby_result.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that custom fact 4 is available" do
      create_api_call_file(test_vars, "puts Facter.value('custom_fact_4')")
      on(agent, "#{ruby_command(agent)} #{test_vars[:fact_query_file_path]}") do |ruby_result|
        assert_match(/custom_fact_4_value/, ruby_result.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that a core fact is still available" do
      os_name = on(agent, facter('os.name')).stdout.chomp
      create_api_call_file(test_vars, "puts Facter.value('os.name')")
      on(agent, "#{ruby_command(agent)} #{test_vars[:fact_query_file_path]}") do |ruby_result|
        assert_match(/#{os_name}/, ruby_result.stdout)
      end
    end

    step "Agent #{agent}: Verify that an error is outputted when custom fact file has an error" do
      create_api_call_file(test_vars, "Facter.value('custom_fact_1')")
      on(agent, "#{ruby_command(agent)} #{test_vars[:fact_query_file_path]}") do |ruby_result|
        assert_match(/Facter - error while resolving custom facts in .*file1.rb undefined local variable or method `nill'/,
          ruby_result.stdout)
      end
    end

    step "Agent #{agent}: Verify that Fact.to_hash still works" do
      create_api_call_file(test_vars, "puts Facter.to_hash")
      on(agent, "#{ruby_command(agent)} #{test_vars[:fact_query_file_path]}") do |ruby_result|
        assert_match(/os.name/, ruby_result.stdout)
      end
    end
  end
end
