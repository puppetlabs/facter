# This test is intended to demonstrate that setting cli.verbose to true in the 
# config file causes INFO level logging to output to stderr.
test_name "verbose config field prints verbose information to stderr" do
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  config = <<EOM
cli : {
    verbose : true
}
EOM

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      config_file = File.join(config_dir, "facter.conf")
      on(agent, "mkdir -p '#{config_dir}'")
      create_remote_file(agent, config_file, config)

      teardown do
        on(agent, "rm -rf '#{config_dir}'", :acceptable_exit_codes => [0,1])
      end

      step "debug output should print when config file is loaded" do
        on(agent, facter("")) do
          assert_match(/INFO/, stderr, "Expected stderr to contain verbose (INFO) statements")
        end
      end
    end
  end
end

