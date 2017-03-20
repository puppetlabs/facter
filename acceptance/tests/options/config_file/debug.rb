# This test is intended to demonstrate that setting the cli.debug field to true
# causes DEBUG information to be printed to stderr.
test_name "C99965: setting the debug config field to true prints debug info to stderr" do
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  config = <<EOM
cli : {
    debug : true
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
          assert_match(/DEBUG/, stderr, "Expected DEBUG information in stderr")
        end
      end
    end
  end
end

