test_name "Can resolve custom facts that call legacy facts"  do
  tag 'risk:high'

  fact_content = <<-RUBY
    Facter.add(:test_fact_with_legacy) do
      setcode do
        Facter.value('osfamily').downcase
        'resolved'
      end
    end
  RUBY

  agents.each do |agent|
    fact_dir = agent.tmpdir('fact')
    fact_file = File.join(fact_dir, 'test_fact.rb')
    create_remote_file(agent, fact_file, fact_content)

    teardown do
      agent.rm_rf(fact_dir)
    end

    step 'it resolves the fact without errors' do
      on(agent, facter("--custom-dir #{fact_dir} --json")) do |facter_result|
        assert_equal(
          'resolved',
          JSON.parse(facter_result.stdout.chomp)['test_fact_with_legacy'],
          'test_fact_with_legacy value is wrong'
        )
        assert_empty(facter_result.stderr.chomp, "Expected no errors from facter")
      end
    end
  end
end
