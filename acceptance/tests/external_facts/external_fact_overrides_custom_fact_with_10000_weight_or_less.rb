test_name "C100151: external fact overrides a custom fact of weight 10000 or less" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  fact_name = 'test'
  # Use a static external fact
  ext_fact = "#{fact_name}: 'EXTERNAL'"

  agents.each do |agent|
    facts_dir = agent.tmpdir('facts.d')
    ext_fact_path = "#{facts_dir}/test.yaml"
    cust_fact_path = "#{facts_dir}/test.rb"
    create_remote_file(agent, ext_fact_path, ext_fact)
    create_remote_file(agent, cust_fact_path, custom_fact_content(fact_name, 'CUSTOM', "has_weight 10000"))

    teardown do
      agent.rm_rf(facts_dir)
    end

    # Custom fact with weight <= 10000 should give precedence to the EXTERNAL fact
    step "Agent #{agent}: resolve an external fact over the custom fact with a weight of 10000" do
      on(agent, facter("--external-dir \"#{facts_dir}\" --custom-dir \"#{facts_dir}\" #{fact_name}")) do |facter_output|
        assert_equal("EXTERNAL", facter_output.stdout.chomp)
      end
    end
  end
end

