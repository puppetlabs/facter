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

  def create_custom_fact_file(file_name, file_content, agent, folder)
    fact_file = File.join(folder, file_name)
    create_remote_file(agent, fact_file, file_content)
  end

  def create_api_call_file(test_vars, facter_querry)
    file_content = <<-EOM
      require 'facter'
      #{'Facter.trace(true)' if @options[:trace]}
      Facter.search(\'#{test_vars[:facts_dir]}\')
      #{facter_querry}
    EOM
    create_custom_fact_file(test_vars[:test_script_name], file_content, test_vars[:agent], test_vars[:script_dir])
  end

  agents.each do |agent|
    test_vars = {}
    test_vars[:facts_dir] = agent.tmpdir('facts_dir')
    test_vars[:script_dir] = agent.tmpdir('script_dir')
    test_vars[:agent] = agent
    test_vars[:test_script_name] = 'test_custom_facts.rb'
    test_vars[:test_script_path] = File.join(test_vars[:script_dir], test_vars[:test_script_name])

    create_custom_fact_file('file1.rb', first_file_content, test_vars[:agent], test_vars[:facts_dir])
    create_custom_fact_file('file2.rb', second_file_content, test_vars[:agent], test_vars[:facts_dir])

    teardown do
      agent.rm_rf(test_vars[:facts_dir])
      agent.rm_rf(test_vars[:script_dir])
    end

    step "Agent #{agent}: Verify that custom fact 1 is available" do
      create_api_call_file(test_vars, "puts Facter.value('custom_fact_1')")
      on(agent, "#{ruby_command(agent)} #{test_vars[:test_script_path]}") do |ruby_result|
        assert_match(/custom_fact_1_value/, ruby_result.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that custom fact 2 is missing" do
      create_api_call_file(test_vars, "puts Facter.value('custom_fact_2')")
      on(agent, "#{ruby_command(agent)} #{test_vars[:test_script_path]}") do |ruby_result|
        assert_no_match(/custom_fact_2_value/, ruby_result.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that custom fact 3 is missing" do
      create_api_call_file(test_vars, "puts Facter.value('custom_fact_3')")
      on(agent, "#{ruby_command(agent)} #{test_vars[:test_script_path]}") do |ruby_result|
        assert_no_match(/custom_fact_3_value/, ruby_result.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that custom fact 4 is available" do
      create_api_call_file(test_vars, "puts Facter.value('custom_fact_4')")
      on(agent, "#{ruby_command(agent)} #{test_vars[:test_script_path]}") do |ruby_result|
        assert_match(/custom_fact_4_value/, ruby_result.stdout.chomp)
      end
    end

    step "Agent #{agent}: Verify that a core fact is still available" do
      os_name = on(agent, facter("os.name #{@options[:trace]}")).stdout.chomp
      create_api_call_file(test_vars, "puts Facter.value('os.name')")
      on(agent, "#{ruby_command(agent)} #{test_vars[:test_script_path]}") do |ruby_result|
        assert_match(/#{os_name}/, ruby_result.stdout)
      end
    end

    step "Agent #{agent}: Verify that an error is outputted when custom fact file has an error" do
      create_api_call_file(test_vars, "Facter.value('custom_fact_1')")
      on(agent, "#{ruby_command(agent)} #{test_vars[:test_script_path]}") do |ruby_result|
        assert_match(/Facter.*error while resolving custom facts in .*file1.rb undefined local variable or method `nill'/,
          ruby_result.stdout)
      end
    end

    step "Agent #{agent}: Verify that Fact.to_hash still works" do
      create_api_call_file(test_vars, "puts Facter.to_hash")
      on(agent, "#{ruby_command(agent)} #{test_vars[:test_script_path]}") do |ruby_result|
        assert_match(/os.name/, ruby_result.stdout)
      end
    end
  end
end

