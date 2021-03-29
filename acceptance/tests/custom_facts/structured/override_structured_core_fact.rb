# frozen_string_literal: true

test_name 'custom structured facts can override parts of core facts' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  core_fact = 'os'
  fact_file = 'custom_fact.rb'
  fact_name = 'name'
  fact_value = 'test'

  fact_content = <<-RUBY
  Facter.add('#{core_fact}.#{fact_name}', weight: 999, type: :structured) do
    setcode do
      "#{fact_value}"
    end
  end
  RUBY

  agents.each do |agent|
    builtin_value = JSON.parse(on(agent, facter('os  --json')).stdout.chomp)
    builtin_value['os'][fact_name] = fact_value
    expected_value = builtin_value

    fact_dir = agent.tmpdir('custom_facts')
    fact_file = File.join(fact_dir, fact_file)
    create_remote_file(agent, fact_file, fact_content)

    teardown do
      agent.rm_rf(fact_dir)
    end

    step 'check that core fact is extended' do
      on(agent, facter("os --custom-dir=#{fact_dir} --json")) do |facter_output|
        assert_equal(
          expected_value,
          JSON.parse(facter_output.stdout.chomp)
        )
      end

      on(agent, facter("os.name --custom-dir=#{fact_dir}")) do |facter_output|
        assert_equal(
          fact_value,
          facter_output.stdout.chomp
        )
      end
    end
  end
end
