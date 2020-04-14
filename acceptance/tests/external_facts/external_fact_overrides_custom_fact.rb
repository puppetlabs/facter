test_name "C100150: external fact overrides custom fact without a weight" do
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
    create_remote_file(agent, cust_fact_path, custom_fact_content(fact_name, 'CUSTOM'))
    create_remote_file(agent, ext_fact_path, ext_fact)

    teardown do
      agent.rm_rf(facts_dir)
    end

    step "Agent #{agent}: resolve an external fact over a custom fact" do
      on(agent, facter("--external-dir=#{facts_dir} --custom-dir=#{facts_dir} #{fact_name}")) do |facter_output|
        assert_equal("EXTERNAL", facter_output.stdout.chomp)
      end
    end
  end
end

