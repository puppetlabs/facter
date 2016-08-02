test_name "verbose config field prints verbose information to stderr"
#
# This test is intended to demonstrate that setting cli.verbose to true in the 
# config file causes INFO level logging to output to stderr.
#
config = <<EOM
cli : {
    verbose : true
}
EOM

agents.each do |agent|
  step "Agent #{agent}: create config file"
  config_dir = agent.tmpdir("config_dir")
  config_file = File.join(config_dir, "facter.conf")
  create_remote_file(agent, config_file, config)

  step "debug output should print when config file is loaded"
  on(agent, facter("--config '#{config_file}'")) do
    assert_match(/INFO/, stderr, "Expected stderr to contain verbose (INFO) statements")
  end
end

