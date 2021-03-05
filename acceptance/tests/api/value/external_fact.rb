# frozen_string_literal: true

test_name 'Facter.value(external_fact)' do
  confine :to, platform: 'ubuntu'
  tag 'audit:high'

  require 'facter/acceptance/base_fact_utils'
  require 'facter/acceptance/api_utils'
  extend Facter::Acceptance::BaseFactUtils
  extend Facter::Acceptance::ApiUtils

  agents.each do |agent|
    facts_dir = agent.tmpdir('facts')
    fact_name = 'my_external_fact'

    teardown do
      agent.rm_rf(facts_dir)
    end

    fact_file = File.join(facts_dir, 'external.txt')
    fact_content = 'my_external_fact=123'

    create_remote_file(agent, fact_file, fact_content)

    step 'returns external fact without loading custom facts' do
      facter_rb = facter_value_rb(agent, fact_name, external_dir: facts_dir, debug: true)
      on(agent, "#{ruby_command(agent)} #{facter_rb}") do |result|
        output = result.stdout.strip
        assert_match(/has resolved to: 123/, output, 'Incorrect fact value for external fact')
        assert_no_match(/in all custom facts/, output, 'Loaded all custom facts')
      end
    end
  end
end
