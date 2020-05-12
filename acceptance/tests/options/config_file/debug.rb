# This test is intended to demonstrate that setting the cli.debug field to true
# causes DEBUG information to be printed to stderr.
test_name "C99965: setting the debug config field to true prints debug info to stderr" do
  tag 'risk:high'

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
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config)

      teardown do
        agent.rm_rf(config_dir)
      end

      step "debug output should print when config file is loaded" do
        on(agent, facter("")) do |facter_output|
          assert_match(/DEBUG/, facter_output.stderr, "Expected DEBUG information in stderr")
        end
      end
    end
  end
end

