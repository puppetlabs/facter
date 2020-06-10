# facter should be able to be called with multiple --custom-dir's and find a fact in each
# directory specified
test_name "C99999: custom fact commandline option --custom-dir can be specified multiple times" do
  tag 'risk:high'

  require 'json'
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  content_1 = <<EOM
Facter.add('custom_fact_1') do
  setcode do
    "testvalue_1"
  end
end
EOM

  content_2 = <<EOM
Facter.add('custom_fact_2') do
  setcode do
    "testvalue_2"
  end
end
EOM

  agents.each do |agent|
    step "Agent #{agent}: create custom fact directory and a custom fact in each" do
      custom_dir_1 = agent.tmpdir('custom_dir_1')
      custom_dir_2 = agent.tmpdir('custom_dir_2')
      custom_fact_1 = File.join(custom_dir_1, 'custom_fact.rb')
      custom_fact_2 = File.join(custom_dir_2, 'custom_fact.rb')
      create_remote_file(agent, custom_fact_1, content_1)
      create_remote_file(agent, custom_fact_2, content_2)

      teardown do
        agent.rm_rf(custom_dir_1)
        agent.rm_rf(custom_dir_2)
      end

      step "Agent #{agent}: resolve a fact from each specified --custom-dir option" do
        on(agent, facter("--custom-dir \"#{custom_dir_1}\" --custom-dir \"#{custom_dir_2}\" --json")) do |facter_output|
          results = JSON.parse(facter_output.stdout)
          assert_equal("testvalue_1", results['custom_fact_1'], "Incorrect custom fact value for custom_fact_1")
          assert_equal("testvalue_2", results['custom_fact_2'], "Incorrect custom fact value for custom_fact_2")
        end
      end
    end
  end
end
