# This test is intended to demonstrate that all command-line flags take precedence
# over their counterparts in the config file. This only applies to exact repeats;
# if a command-line flag conflicts with a config file setting, a warning will be
# issued the same as if the user had specified two conflicting flags on the command
# line.
test_name "flags set on the command line override config file settings" do
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  config = <<EOM
global : {
    external-dir : "config/file/dir"
}
cli : {
    debug : false
}
EOM

  agents.each do |agent|
    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, "facter.conf")

    teardown do
      on(agent, "rm -rf '#{config_dir}'", :acceptable_exit_codes => [0,1])
    end

    step "Agent #{agent}: create config file in default location" do
      on(agent, "mkdir -p '#{config_dir}'")
      create_remote_file(agent, config_file, config)
    end

    step "--debug flag should override debug=false in config file" do
       on(agent, facter("--debug")) do |facter_output|
         assert_match(/DEBUG/, facter_output.stderr, "Expected DEBUG information in stderr")
       end
     end

    step "conflict logic applies across settings sources" do
      on(agent, facter("--no-external-facts"), :acceptable_exit_codes => [1]) do |facter_output|
       assert_match(/no-external-facts and external-dir options conflict/, facter_output.stderr, "Facter should have warned about conflicting settings")
      end
    end
  end
end
