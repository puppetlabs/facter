# This test is intended to demonstrate that the directory for custom facts can be specified from
# the config file using the global.custom-dir field, and that custom fact collection can be disabled
# by setting the global.no-custom-facts field to true.
test_name "custom-dir and no-custom-facts config fields allow control of custom fact lookup" do
  require 'facter/acceptance/user_fact_utils'
  extend ::Facter::Acceptance::UserFactUtils

  custom_fact_content = <<EOM
Facter.add('custom_fact') do
  setcode do
   "testvalue"
  end
end
EOM

  agents.each do |agent|
    custom_dir = get_user_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

    step "Agent #{agent}: create custom fact and config file" do
      on(agent, "mkdir -p '#{custom_dir}'")
      custom_fact = File.join(custom_dir, 'custom_fact.rb')
      create_remote_file(agent, custom_fact, custom_fact_content)

      config_custom = <<EOM
global : {
    custom-dir : "#{custom_dir}"
}
EOM

      config_dir = agent.tmpdir("config_dir")
      config_custom_file = File.join(config_dir, "custom.conf")
      create_remote_file(agent, config_custom_file, config_custom)

      config_no_custom = <<EOM
global : {
    no-custom-facts : true
}
cli : {
    debug : true
}
EOM

      config_no_custom_file = File.join(config_dir, "no_custom.conf")
      create_remote_file(agent, config_no_custom_file, config_no_custom)

      teardown do
        on(agent, "rm -rf '#{custom_dir}' '#{config_dir}'", :acceptable_exit_codes => [0,1])
      end

      step "setting custom-dir in config file should specify location to look for custom facts" do
        on(agent, facter("--config '#{config_custom_file}' custom_fact")) do
          assert_equal("testvalue", stdout.chomp, "Custom fact output does not match expected output")
        end
      end

      step "setting no-custom-facts to true should prevent custom fact lookup" do
        on(agent, facter("--config '#{config_no_custom_file}'")) do
          assert_no_match(/loading all custom facts/, stderr, "Facter should not load custom facts")
        end
      end
    end
  end
end
