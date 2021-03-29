# frozen_string_literal: true

test_name 'external facts override parts of custom_facts' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  ext_fact_name = 'key1.key2'
  ext_fact_value = 'EXTERNAL'
  ext_fact_content = "#{ext_fact_name}: '#{ext_fact_value}'"
  custom_fact_file = 'custom_fact.rb'

  fact_content = <<-RUBY
  Facter.add('ke1.key12') do
    setcode do
      "custom1"
    end
  end

  Facter.add('key1.key3') do
    setcode do
      "custom2"
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

    external_dir = agent.tmpdir('facts.d')
    agent.mkdir_p(external_dir)
    ext_fact_path = File.join(external_dir, 'test.yaml')
    create_remote_file(agent, ext_fact_path, ext_fact_content)

    custom_facts_dir = agent.tmpdir('custom_facts')
    custom_fact_file = File.join(custom_facts_dir, custom_fact_file)
    create_remote_file(agent, custom_fact_file, fact_content)

    teardown do
      agent.rm_rf(external_dir)
      agent.rm_rf(config_dir)
      agent.rm_rf(custom_facts_dir)
    end

    step 'overwtites part of the custom fact' do
      on(
        agent,
        facter("--external-dir \"#{external_dir}\" --custom-dir \"#{custom_facts_dir}\" key1 --json")
      ) do |facter_output|
        assert_equal(
          { 'key1' =>
            {
              'key2' => ext_fact_value,
              'key3' => 'custom2'
            } },
          JSON.parse(facter_output.stdout.chomp)
        )
      end
    end
  end
end
