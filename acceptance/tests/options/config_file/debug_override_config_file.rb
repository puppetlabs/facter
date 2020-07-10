# This test verified that having debug set to false in the config file can be
# overridden by the command line option --debug
test_name "C100044: flags set on the command line override config file settings" do
  tag 'risk:medium'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  config = <<EOM
cli : {
    debug : false
}
EOM

  agents.each do |agent|
    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, "facter.conf")

    teardown do
      on(agent, "rm -rf '#{config_dir}'", :acceptable_exit_codes => [0, 1])
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
  end
end
