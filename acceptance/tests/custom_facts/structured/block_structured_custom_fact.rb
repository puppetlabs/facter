# frozen_string_literal: true

test_name 'strucutured custom facts can be blocked' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  fact_file = 'custom_fact.rb'
  fact_1_name = 'key1.key2'
  fact_2_name = 'key1.key3'
  fact_1_value = 'test1'
  fact_2_value = 'test2'

  fact_content = <<-RUBY
  Facter.add('#{fact_1_name}', type: :structured) do
    setcode do
      "#{fact_1_value}"
    end
  end

  Facter.add('#{fact_2_name}', type: :structured) do
    setcode do
      "#{fact_2_value}"
    end
  end
  RUBY

  config_data = <<~HOCON
    facts : {
      blocklist : [ "#{fact_1_name}" ],
    }
  HOCON

  agents.each do |agent|
    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, 'facter.conf')
    agent.mkdir_p(config_dir)
    create_remote_file(agent, config_file, config_data)

    fact_dir = agent.tmpdir('custom_facts')
    fact_file = File.join(fact_dir, fact_file)
    create_remote_file(agent, fact_file, fact_content)

    teardown do
      agent.rm_rf(fact_dir)
      agent.rm_rf(config_dir)
    end

    step 'blocked structured custom fact is not displayed' do
      on(agent, facter("--custom-dir=#{fact_dir} key1.key2")) do |facter_output|
        assert_equal('', facter_output.stdout.chomp)
      end
    end

    step 'the remaining structured fact is displayed' do
      on(agent, facter("--custom-dir=#{fact_dir} key1.key3")) do |facter_output|
        assert_equal(fact_2_value, facter_output.stdout.chomp)
      end
    end
  end
end
