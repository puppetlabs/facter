# This test verifies that when a fact group is blocked in the config file
# the corresponding facts do not resolve.
test_name "C99972: facts can be blocked via a blocklist in the config file" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      custom_conf_dir = agent.tmpdir("config_dir")
      config_file = File.join(custom_conf_dir, "facter.conf")
      create_remote_file(agent, config_file, <<-FILE)
        cli : { debug : true }
        facts : { blocklist : [ "file system", "EC2" ] }
      FILE

      teardown do
        agent.rm_rf(custom_conf_dir)
      end

      step "blocked facts should not be resolved" do
        on(agent, facter("--config \"#{config_file}\"")) do |facter_output|
          # every platform attempts to resolve at least EC2 facts
          assert_match(/blocking collection of .+ facts/, facter_output.stderr, "Expected stderr to contain statement about blocking fact collection")

          # on some platforms, file system facts are never resolved, so this will also be true in those cases
          assert_no_match(/filesystems/, facter_output.stdout, "filesystems fact should have been blocked")
          assert_no_match(/mountpoints/, facter_output.stdout, "mountpoints fact should have been blocked")
          assert_no_match(/partitions/, facter_output.stdout, "partitions fact should have been blocked")
        end
      end
    end
  end
end
