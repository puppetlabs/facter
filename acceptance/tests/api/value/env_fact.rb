# frozen_string_literal: true

test_name 'Facter.value(env_fact)' do
  confine :to, platform: 'ubuntu'
  tag 'audit:high'

  require 'facter/acceptance/base_fact_utils'
  require 'facter/acceptance/api_utils'
  extend Facter::Acceptance::BaseFactUtils
  extend Facter::Acceptance::ApiUtils

  agents.each do |agent|
    fact_name = 'env_fact'
    fact_value = 'env_value'

    step 'resolves the fact with the correct value' do
      facter_rb = facter_value_rb(agent, fact_name)

      env = { "FACTER_#{fact_name}" => fact_value }

      on(agent, "#{ruby_command(agent)} #{facter_rb}", environment: env) do |result|
        assert_match(fact_value, result.stdout.chomp, 'Incorrect fact value for env fact')
      end
    end
  end
end
