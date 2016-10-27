# This test verifies that when a fact group is blocked in the config file
# the corresponding facts do not resolve.
test_name "facts can be blocked via a list in the config file" do
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    step "facts should be blocked when Facter is run from the command line" do
      step "Agent #{agent}: create config file" do
        custom_conf_dir = agent.tmpdir("config_dir")
        config_file = File.join(custom_conf_dir, "facter.conf")
        create_remote_file(agent, config_file, <<-FILE)
        cli : { debug : true }
        facts : { blocklist : [ "file system", "EC2" ] }
        FILE

        teardown do
          on(agent, "rm -rf '#{custom_conf_dir}'", :acceptable_exit_codes => [0, 1])
        end

        step "blocked facts should not be resolved" do
          on(agent, facter("--config '#{config_file}'")) do
            # every platform attempts to resolve at least EC2 facts
            assert_match(/blocking collection of .+ facts/, stderr, "Expected stderr to contain statement about blocking fact collection")

            # on some platforms, file system facts are never resolved, so this will also be true in those cases
            assert_no_match(/filesystems/, stdout, "filesystems fact should have been blocked")
            assert_no_match(/mountpoints/, stdout, "mountpoints fact should have been blocked")
            assert_no_match(/partitions/, stdout, "partitions fact should have been blocked")
          end
        end
      end
    end

    step "facts should be blocked when Facter is run from Puppet" do
      # default facter.conf
      facter_conf_default_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      facter_conf_default_path = File.join(facter_conf_default_dir, "facter.conf")

      teardown do
        on(agent, "rm -rf '#{facter_conf_default_dir}'",
            :acceptable_exit_codes => [0,1])
      end

      step "Agent #{agent}: create default config file" do
        # create the directories
        on(agent, "mkdir -p '#{facter_conf_default_dir}'")
        create_remote_file(agent, facter_conf_default_path, <<-FILE)
        facts : { blocklist : [ "file system", "EC2" ] }
        FILE
      end

      step "blocked facts should not be resolved" do
        on(agent, puppet("facts --debug")) do
          # every platform attempts to resolve at least EC2 facts
          assert_match(/blocking collection of .+ facts/, stdout, "Expected stderr to contain statement about blocking fact collection")

          # on some platforms, file system facts are never resolved, so this will also be true in those cases
          assert_no_match(/filesystems/, stdout, "filesystems fact should have been blocked")
          assert_no_match(/mountpoints/, stdout, "mountpoints fact should have been blocked")
          assert_no_match(/partitions/, stdout, "partitions fact should have been blocked")
        end
      end
    end
  end
end
