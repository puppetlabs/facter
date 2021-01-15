# frozen_string_literal: true

test_name 'Facter should handle aggregated custom facts' do
  tag 'risk:high'

  fact_content1 = <<-RUBY
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
  RUBY

  fact_content2 = <<-RUBY
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
  RUBY

  fact_content3 = <<-RUBY
    Facter.add(:test_array_fact, :type => :aggregate) do
      has_weight 100000
      chunk(:one) do
        ['foo']
      end

      chunk(:two) do
        ['bar']
      end
    end

    Facter.add(:test_hash_fact, :type => :aggregate) do
      chunk :first do
        { foo: 'aggregate' }
      end

      chunk :second do
        { bar: 'fact' }
      end
    end
  RUBY

  agents.each do |agent|
    fact_dir1 = agent.tmpdir('fact1')
    fact_file1 = File.join(fact_dir1, 'test_facts.rb')
    create_remote_file(agent, fact_file1, fact_content1)

    fact_dir2 = agent.tmpdir('fact2')
    fact_file2 = File.join(fact_dir2, 'test_facts.rb')
    create_remote_file(agent, fact_file2, fact_content2)

    fact_dir3 = agent.tmpdir('fact3')
    fact_file3 = File.join(fact_dir3, 'no_aggregate_block.rb')
    create_remote_file(agent, fact_file3, fact_content3)

    teardown do
      agent.rm_rf(fact_dir1)
      agent.rm_rf(fact_dir2)
      agent.rm_rf(fact_dir3)
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

    step "Agent: Verify aggregate facts with no aggregate block from #{fact_file3}" do
      on(agent, facter("--custom-dir #{fact_dir3} test_array_fact --debug --json")) do |facter_result|
        assert_equal(
          { 'test_array_fact' => %w[foo bar] },
          JSON.parse(facter_result.stdout.chomp), '
          test_array_fact value is wrong'
        )
        assert_match(
          /custom fact test_array_fact got resolved from.*no_aggregate_block\.rb\", 1\]/,
          facter_result.stderr.chomp,
          'resolution location not found on debug'
        )
      end

      on(agent, facter("--custom-dir #{fact_dir3} test_hash_fact --debug --json")) do |facter_result|
        assert_equal(
          { 'test_hash_fact' => { 'bar' => 'fact', 'foo' => 'aggregate' } },
          JSON.parse(facter_result.stdout.chomp),
          'test_hash_fact value is wrong'
        )
        assert_match(
          /custom fact test_hash_fact got resolved from.*no_aggregate_block\.rb\", 12\]/,
          facter_result.stderr.chomp,
          'resolution location not found on debug'
        )
      end
    end
  end
end
