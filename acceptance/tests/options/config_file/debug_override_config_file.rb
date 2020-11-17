# This test verified that having debug set to false in the config file can be
# overridden by the command line option --debug
test_name "C100044: flags set on the command line override config file settings" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  config = <<EOM
cli : {
    debug : false
}
EOM

  agents.each do |agent|
    config_dir = get_default_fact_dir(agent['platform'],
                                      on(agent, facter("kernelmajversion #{@options[:trace]}")).stdout.chomp.to_f)
    config_file = File.join(config_dir, "facter.conf")

    teardown do
      agent.rm_rf(config_dir)
    end

    step "Agent #{agent}: create config file in default location" do
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config)
    end

    step "--debug flag should override debug=false in config file" do
      on(agent, facter("--debug #{@options[:trace]}")) do |facter_output|
        assert_match(/DEBUG/, facter_output.stderr, "Expected DEBUG information in stderr")
      end
    end
  end
end
