# frozen_string_literal: true

test_name 'custom structured facts can extend core facts' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  core_fact = 'os'
  fact_file = 'custom_fact.rb'
  fact_name = 'extension'
  fact_value = 'test'

  fact_content = <<-RUBY
  Facter.add('#{core_fact}.#{fact_name}') do
    setcode do
      "#{fact_value}"
    end
  end
  RUBY

  config_data = <<~HOCON
    global : {
      force-dot-resolution : true
    }
  HOCON

  agents.each do |agent|
    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, 'facter.conf')
    agent.mkdir_p(config_dir)
    create_remote_file(agent, config_file, config_data)

    builtin_value = JSON.parse(on(agent, facter('os  --json')).stdout.chomp)
    builtin_value['os'][fact_name] = fact_value
    expected_value = builtin_value

    fact_dir = agent.tmpdir('custom_facts')
    fact_file = File.join(fact_dir, fact_file)
    create_remote_file(agent, fact_file, fact_content)

    teardown do
      agent.rm_rf(fact_dir)
      agent.rm_rf(config_dir)
    end

    step 'check that core fact is extended' do
      on(agent, facter("os --custom-dir=#{fact_dir} --json")) do |facter_output|
        assert_equal(
          expected_value,
          JSON.parse(facter_output.stdout.chomp)
        )
      end
    end
  end
end
