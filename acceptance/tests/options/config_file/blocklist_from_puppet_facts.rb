# This test verifies that when a fact group is blocked in the config file the
# corresponding facts do not resolve when being run from the puppet facts command.
test_name "C100036: when run from puppet facts, facts can be blocked via a list in the config file" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    step "facts should be blocked when Facter is run from Puppet with a configured blocklist" do
      # default facter.conf
      facter_conf_default_dir = get_default_fact_dir(agent['platform'],
                                                     on(agent, facter("kernelmajversion #{@options[:trace]}")).stdout.chomp.to_f)
      facter_conf_default_path = File.join(facter_conf_default_dir, "facter.conf")

      teardown do
        agent.rm_rf(facter_conf_default_dir)
      end

      step "Agent #{agent}: create default config file" do
        # create the directories
        agent.mkdir_p(facter_conf_default_dir)
        create_remote_file(agent, facter_conf_default_path, <<-FILE)
        facts : { blocklist : [ "file system", "EC2" ] }
        FILE
      end

      step "blocked facts should not be resolved" do
        on(agent, puppet("facts --debug")) do |puppet_facts_output|
          # every platform attempts to resolve at least EC2 facts
          assert_match(/blocking collection of .+ facts/, puppet_facts_output.stdout, "Expected stderr to contain statement about blocking fact collection")

          # on some platforms, file system facts are never resolved, so this will also be true in those cases
          assert_no_match(/filesystems/, puppet_facts_output.stdout, "filesystems fact should have been blocked")
          assert_no_match(/mountpoints/, puppet_facts_output.stdout, "mountpoints fact should have been blocked")
          assert_no_match(/partitions/, puppet_facts_output.stdout, "partitions fact should have been blocked")
        end
      end
    end
  end
end
