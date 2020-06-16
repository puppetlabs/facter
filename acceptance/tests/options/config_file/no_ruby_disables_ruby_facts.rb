# This test verifies that the global.no-ruby config file field disables
# ruby facts
test_name "C99964: no-ruby config field flag disables requiring Ruby" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  config = <<EOM
global : {
    no-ruby : true
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

      step "no-ruby option should disable Ruby and facts requiring Ruby" do
        on(agent, facter("ruby")) do |facter_output|
          assert_equal("", facter_output.stdout.chomp, "Expected Ruby and Ruby fact to be disabled")
          assert_equal("", facter_output.stderr.chomp, "Expected no warnings about Ruby on stderr")
        end
      end
    end
  end
end
