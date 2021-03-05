# frozen_string_literal: true

test_name 'Facter.value(custom_fact) in different file' do
  confine :to, platform: 'ubuntu'
  tag 'audit:high'

  require 'facter/acceptance/base_fact_utils'
  require 'facter/acceptance/api_utils'
  extend Facter::Acceptance::BaseFactUtils
  extend Facter::Acceptance::ApiUtils

  agents.each do |agent|
    facts_dir = agent.tmpdir('facts')
    fact_name = 'single_custom_fact'

    teardown do
      agent.rm_rf(facts_dir)
    end

    fact_file = File.join(facts_dir, 'another_fact.rb')
    fact_content = <<-RUBY
        Facter.add('#{fact_name}') do
          setcode { 'single_custom_fact' }
        end
    RUBY

    create_remote_file(agent, fact_file, fact_content)

    step 'returns custom_fact fact value after loading all custom facts' do
      facter_rb = facter_value_rb(agent, fact_name, custom_dir: facts_dir, debug: true)
      on(agent, "#{ruby_command(agent)} #{facter_rb}") do |result|
        output = result.stdout.strip
        assert_match(/has resolved to: #{fact_name}/, output, 'Incorrect fact value for custom fact')
        assert_match(/Searching fact: #{fact_name} in all custom facts/, output, 'Loaded all custom facts')
      end
    end
  end
end
