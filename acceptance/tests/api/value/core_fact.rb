# frozen_string_literal: true

test_name 'Facter.value(core_fact)' do
  confine :to, platform: 'ubuntu'
  tag 'audit:high'

  require 'facter/acceptance/base_fact_utils'
  require 'facter/acceptance/api_utils'
  extend Facter::Acceptance::BaseFactUtils
  extend Facter::Acceptance::ApiUtils

  agents.each do |agent|
    fact_name = 'os.name'
    core_fact_value = os_processors_and_kernel_expected_facts(agent)[fact_name]

    step 'returns core fact value' do
      facter_rb = facter_value_rb(agent, fact_name)
      fact_value = on(agent, "#{ruby_command(agent)} #{facter_rb}").stdout&.strip

      assert_match(fact_value, core_fact_value, 'Incorrect fact value for os.name')
    end
  end
end
