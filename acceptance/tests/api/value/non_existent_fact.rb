# frozen_string_literal: true

test_name 'Facter.value(not_existent)' do
  confine :to, platform: 'ubuntu'
  tag 'audit:high'

  require 'facter/acceptance/base_fact_utils'
  require 'facter/acceptance/api_utils'
  extend Facter::Acceptance::BaseFactUtils
  extend Facter::Acceptance::ApiUtils

  agents.each do |agent|
    fact_name = 'non_existent'
    facts_dir = agent.tmpdir('facts')

    teardown do
      agent.rm_rf(facts_dir)
    end

    step 'it loads facts in the correct order' do
      facter_rb = facter_value_rb(
        agent, fact_name,
        external_dir: facts_dir,
        custom_dir: facts_dir,
        debug: true
      )

      on(agent, "#{ruby_command(agent)} #{facter_rb}") do |result|
        output = result.stdout.strip
        refute_match(/has resolved to: /, output, 'Fact was found')
        assert_match(
          /Searching fact: #{fact_name} in file: #{fact_name}.rb/,
          output,
          'Did not load fact name file'
        )
        assert_match(
          /Searching fact: #{fact_name} in core facts and external facts/,
          output,
          'Did not load core and external'
        )
        assert_match(
          /Searching fact: #{fact_name} in all custom facts/,
          output, '
          Did not load all custom facts'
        )
      end
    end
  end
end
