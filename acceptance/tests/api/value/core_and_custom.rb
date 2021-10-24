# frozen_string_literal: true

test_name 'Facter.value(core_fact) when custom fact is defined' do
  confine :to, platform: 'ubuntu'
  tag 'audit:high'

  require 'facter/acceptance/base_fact_utils'
  require 'facter/acceptance/api_utils'
  extend Facter::Acceptance::BaseFactUtils
  extend Facter::Acceptance::ApiUtils

  agents.each do |agent|
    fact_name = 'os.name'
    core_fact_value = os_processors_and_kernel_expected_facts(agent)[fact_name]

    step 'in different file than fact name' do
      facts_dir = agent.tmpdir('facts')

      teardown do
        agent.rm_rf(facts_dir)
      end

      fact_file = File.join(facts_dir, 'test_fact.rb')
      fact_content = <<-RUBY
        Facter.add('#{fact_name}') do
          has_weight(100)
          setcode { 'custom_fact' }
        end
      RUBY

      create_remote_file(agent, fact_file, fact_content)

      step 'returns core fact value' do
        facter_rb = facter_value_rb(agent, fact_name, custom_dir: facts_dir)
        fact_value = on(agent, "#{ruby_command(agent)} #{facter_rb}").stdout&.strip

        assert_match(fact_value, core_fact_value, 'Incorrect fact value for os.name')
      end
    end
  end
end
