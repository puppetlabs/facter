test_name "FACT-2874: file containing external facts are loaded in lexicographical order" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  fact_name = 'test'
  # Use a static external fact
  ext_fact1 = "#{fact_name}: 'EXTERNAL1'"
  ext_fact2 = "#{fact_name}: 'EXTERNAL2'"

  agents.each do |agent|
    facts_dir = agent.tmpdir('facts.d')
    ext_fact_path1 = "#{facts_dir}/a_test.yaml"
    ext_fact_path2 = "#{facts_dir}/b_test.yaml"
    create_remote_file(agent, ext_fact_path1, ext_fact1)
    create_remote_file(agent, ext_fact_path2, ext_fact2)

    teardown do
      agent.rm_rf(facts_dir)
    end

    step "Agent #{agent}: resolve external fact with the last value it resolves to" do
      on(agent, facter("--external-dir \"#{facts_dir}\" #{fact_name}")) do |facter_output|
        assert_equal("EXTERNAL2", facter_output.stdout.chomp)
      end
    end
  end
end


