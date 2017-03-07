# This tests is inteded to verify that passing the `--no-block` command to facter will prevent
# fact blocking, desptie a blocklist being specified in the config file.
test_name "the `--no-block` command line flag prevents facts from being blocked" do
  require 'facter/acceptance/user_fact_utils'
  extend ::Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    # default facter.conf
    facter_conf_default_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    facter_conf_default_path = File.join(facter_conf_default_dir, "facter.conf")

    teardown do
      on(agent, "rm -rf '#{facter_conf_default_dir}'", :acceptable_exit_codes => [0, 1])
    end

    # create the directories
    on(agent, "mkdir -p '#{facter_conf_default_dir}'")

    step "Agent #{agent}: create config file" do
      create_remote_file(agent, facter_conf_default_path, <<-FILE)
      cli : { debug : true }
      facts : { blocklist : [ "EC2" ] }
      FILE
    end

    step "no facts should be blocked when `--no-block` is specified" do
      on(agent, facter("--no-block")) do 
        assert_no_match(/blocking collection of .+ facts/, stderr, "Expected no facts to be blocked")
      end
    end
  end
end
