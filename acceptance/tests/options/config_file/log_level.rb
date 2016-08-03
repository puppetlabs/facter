# This test ensures that the cli.log-level config file setting works
# properly. The value of the setting should be a string indicating the
# logging level.
test_name "log-level setting can be used to specific logging level" do
  config = <<EOM
cli : {
    log-level : debug
}
EOM

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      create_remote_file(agent, config_file, config)

      step "log-level set to debug should print DEBUG output to stderr" do
        on(agent, facter("--config '#{config_file}'")) do
          assert_match(/DEBUG/, stderr, "Expected DEBUG information in stderr")
        end
      end
    end
  end
end

