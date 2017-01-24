# This test ensures that the cli.log-level config file setting works
# properly. The value of the setting should be a string indicating the
# logging level.
test_name "log-level setting can be used to specific logging level" do
  require 'facter/acceptance/user_fact_utils'
  extend ::Facter::Acceptance::UserFactUtils

  config = <<EOM
cli : {
    log-level : debug
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

      step "log-level set to debug should print DEBUG output to stderr" do
        on(agent, facter("")) do
          assert_match(/DEBUG/, stderr, "Expected DEBUG information in stderr")
        end
      end
    end
  end
end

