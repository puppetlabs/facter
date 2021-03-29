# frozen_string_literal: true

test_name 'custom facts can be defined structured' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  fact_file = 'custom_fact.rb'
  fact_name = 'key1.key2'
  fact_value = 'test'

  fact_content = <<-RUBY
  Facter.add('#{fact_name}', type: :structured) do
    setcode do
      "#{fact_value}"
    end
  end
  RUBY

  agents.each do |agent|
    fact_dir = agent.tmpdir('custom_facts')
    fact_file = File.join(fact_dir, fact_file)
    create_remote_file(agent, fact_file, fact_content)

    teardown do
      agent.rm_rf(fact_dir)
    end

    step 'access fact with dot' do
      on(agent, facter("--custom-dir=#{fact_dir} key1.key2")) do |facter_output|
        assert_equal(fact_value, facter_output.stdout.chomp)
      end

      on(agent, facter("--custom-dir=#{fact_dir} key1 --json")) do |facter_output|
        assert_equal(
          { 'key1' => { 'key2' => fact_value } },
          JSON.parse(facter_output.stdout.chomp)
        )
      end
    end
  end
end
