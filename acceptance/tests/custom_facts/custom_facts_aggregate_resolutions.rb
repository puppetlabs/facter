test_name 'Facter should handle aggregated custom facts' do
  tag 'risk:high'

  fact_content1 = <<-EOM
    Facter.add(:test_fact) do
      has_weight 100000
      setcode do
        "test fact"
      end
    end

    Facter.add(:test_fact, :type => :aggregate) do
      has_weight 10000
      chunk(:one) do
        'aggregate'
      end
      
      chunk(:two) do
          'fact'
      end

      aggregate do |chunks|
        result = ''
      
        chunks.each_value do |str|
          result += str
        end
      
        result
      end
    end
  EOM

  fact_content2 = <<-EOM
  Facter.add(:test_fact) do
    has_weight 10000
    setcode do
      "test fact"
    end
  end

  Facter.add(:test_fact, :type => :aggregate) do
    has_weight 100000
    chunk(:one) do
      'aggregate'
    end
    
    chunk(:two) do
        'fact'
    end

    aggregate do |chunks|
      result = ''
    
      chunks.each_value do |str|
        result += str
      end
    
      result
    end
  end
EOM

  agents.each do |agent|
    fact_dir1 = agent.tmpdir('fact1')
    fact_file1 = File.join(fact_dir1, 'test_facts.rb')
    create_remote_file(agent, fact_file1, fact_content1)
    
    fact_dir2 = agent.tmpdir('fact2')
    fact_file2 = File.join(fact_dir2, 'test_facts.rb')
    create_remote_file(agent, fact_file2, fact_content2)

    teardown do
      agent.rm_rf(fact_dir1)
      agent.rm_rf(fact_dir2)
    end

    step "Agent: Verify test_fact from #{fact_file1}" do
      on(agent, facter("--custom-dir #{fact_dir1} test_fact")) do |facter_result|
        assert_equal('test fact', facter_result.stdout.chomp, 'test_fact value is wrong')
      end
    end

    step "Agent: Verify test_fact from #{fact_file2} with aggregate fact overwriting the custom one" do
      on(agent, facter("--custom-dir #{fact_dir2} test_fact")) do |facter_result|
        assert_equal('aggregatefact', facter_result.stdout.chomp, 'test_fact value is wrong')
      end
    end
  end
end
