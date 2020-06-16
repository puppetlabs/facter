test_name "C100152: external fact overrides a custom fact with a confine" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  fact_name = "test"
  # Use a static external fact
  ext_fact = "#{fact_name}: 'EXTERNAL'"

  agents.each do |agent|
    # Shared directory for external and custom facts
    facts_dir = agent.tmpdir('facts.d')
    ext_fact_path = "#{facts_dir}/test.yaml"
    cust_fact_path = "#{facts_dir}/test.rb"
    create_remote_file(agent, ext_fact_path, ext_fact)

    agent_kernel = on(agent, facter('kernel')).stdout.chomp
    create_remote_file(agent, cust_fact_path,
                       custom_fact_content(fact_name, 'CUSTOM', "confine :kernel=>'#{agent_kernel}'"))

    teardown do
      agent.rm_rf(facts_dir)
    end

    # External fact should take precedence over a custom fact with a confine
    # (from FACT-1413)
    step "Agent #{agent}: resolve external fact over a custom fact with a confine" do
      on(agent, facter("--external-dir \"#{facts_dir}\" --custom-dir \"#{facts_dir}\" test")) do |facter_output|
        assert_equal("EXTERNAL", facter_output.stdout.chomp)
      end
    end
  end
end

