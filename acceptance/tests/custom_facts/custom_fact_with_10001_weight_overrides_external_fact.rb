test_name "C100153: custom fact with weight of >= 10001 overrides an external fact" do
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
    create_remote_file(agent, cust_fact_path, custom_fact_content(fact_name, 'CUSTOM', "has_weight 10001"))

    teardown do
      agent.rm_rf(facts_dir)
    end

    # Custom fact with weight >= 10001 should override an external fact
    step "Agent #{agent}: resolve a custom fact with weight of 10001 overriding the external fact" do
      on(agent, facter("--external-dir \"#{facts_dir}\" --custom-dir=#{facts_dir} test")) do |facter_output|
        assert_equal("CUSTOM", facter_output.stdout.chomp)
      end
    end
  end
end

