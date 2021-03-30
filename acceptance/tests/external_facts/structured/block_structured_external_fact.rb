# frozen_string_literal: true

test_name 'strucutured external facts can be blocked' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  fact_1_name = 'key1.key2'
  fact_2_name = 'key1.key3'
  fact_1_value = 'test1'
  fact_2_value = 'test2'
  fact_1_content = "#{fact_1_name}=#{fact_1_value}"
  fact_2_content = "#{fact_2_name}=#{fact_2_value}"

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

    external_dir = agent.tmpdir('facts.d')
    facts_dir = File.join(external_dir, 'structured')
    agent.mkdir_p(facts_dir)
    create_remote_file(agent, File.join(facts_dir, 'fact_1.txt'), fact_1_content)
    create_remote_file(agent, File.join(facts_dir, 'fact_2.txt'), fact_2_content)

    teardown do
      agent.rm_rf(external_dir)
      agent.rm_rf(config_dir)
    end

    step 'blocked structured external fact is not displayed' do
      on(agent, facter("--external-dir \"#{external_dir}\" key1.key2")) do |facter_output|
        assert_equal('', facter_output.stdout.chomp)
      end
    end

    step 'the remaining structured fact is displayed' do
      on(agent, facter("--external-dir \"#{external_dir}\" key1.key3")) do |facter_output|
        assert_equal(fact_2_value, facter_output.stdout.chomp)
      end
    end
  end
end
