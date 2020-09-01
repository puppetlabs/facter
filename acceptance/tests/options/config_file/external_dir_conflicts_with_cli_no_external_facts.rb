# This test verifies that a configured external-dir conflicts with the command
# line option --no-external-facts
test_name "configured external-dir conflicts with command line --no-external-facts" do
  tag 'risk:low'

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
      agent.rm_rf(config_dir)
    end

    step "Agent #{agent}: create config file in default location" do
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config)
    end

    step "conflict logic applies across settings sources" do
      on(agent, facter("--no-external-facts"), :acceptable_exit_codes => [1]) do |facter_output|
        assert_match(/no-external-facts and external-dir options conflict/, facter_output.stderr, "Facter should have warned about conflicting settings")
      end
    end
  end
end
