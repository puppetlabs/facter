# frozen_string_literal: true

test_name 'external facts can be defined as structured' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  fact_name = 'key1.key2'
  fact_value = 'EXTERNAL'
  ext_fact_content = "#{fact_name}: '#{fact_value}'"

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

    external_dir = agent.tmpdir('facts.d')
    agent.mkdir_p(external_dir)

    ext_fact_path = File.join(external_dir, 'test.yaml')
    create_remote_file(agent, ext_fact_path, ext_fact_content)

    teardown do
      agent.rm_rf(external_dir)
      agent.rm_rf(config_dir)
    end

    step 'resolve an external structured fact' do
      on(agent, facter("--external-dir \"#{external_dir}\" #{fact_name}")) do |facter_output|
        assert_equal(fact_value, facter_output.stdout.chomp)
      end

      on(agent, facter("--external-dir \"#{external_dir}\" key1 --json")) do |facter_output|
        assert_equal(
          { 'key1' => { 'key2' => fact_value } },
          JSON.parse(facter_output.stdout.chomp)
        )
      end
    end
  end
end
