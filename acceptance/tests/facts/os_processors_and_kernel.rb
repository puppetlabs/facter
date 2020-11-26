test_name 'C100193: Facter os, processors, and kernel facts resolve on all platforms' do
  tag 'risk:high'

  require 'json'
  require 'facter/acceptance/base_fact_utils'
  extend Facter::Acceptance::BaseFactUtils

  agents.each do |agent|
    step 'Ensure the os, processors, and kernel fact resolves as expected' do
      expected_facts = os_processors_and_kernel_expected_facts(agent)
      on(agent, facter("--json #{@options[:trace]}")) do |facter_result|
        results = JSON.parse(facter_result.stdout)
        expected_facts.each do |fact, value|
          actual_fact = json_result_fact_by_key_path(results, fact)
          assert_match(value, actual_fact.to_s, "Incorrect fact value for #{fact}")
        end
      end
    end
  end
end
