# This test is intended to demonstrate that setting cli.verbose to true in the 
# config file causes INFO level logging to output to stderr.
test_name "C99989: verbose config field prints verbose information to stderr" do

  config = <<EOM
cli : {
    verbose : true
}
EOM

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      create_remote_file(agent, config_file, config)

      teardown do
        on(agent, "rm -rf '#{config_dir}'")
      end

      step "debug output should print when config file is loaded" do
        on(agent, facter("--config '#{config_file}'")) do
          assert_match(/INFO/, stderr, "Expected stderr to contain verbose (INFO) statements")
        end
      end
    end
  end
end

