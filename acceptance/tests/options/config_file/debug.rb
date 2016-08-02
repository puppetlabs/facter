test_name "setting the debug config field to true prints debug info to stderr"
#
# This test is intended to demonstrate that setting the cli.debug field to true
# causes DEBUG information to be printed to stderr.
#
config = <<EOM
cli : {
    debug : true
}
EOM

agents.each do |agent|
  step "Agent #{agent}: create config file"
  config_dir = agent.tmpdir("config_dir")
  config_file = File.join(config_dir, "facter.conf")
  create_remote_file(agent, config_file, config)

  step "debug output should print when config file is loaded"
  on(agent, facter("--config '#{config_file}'")) do 
    assert_match(/DEBUG/, stderr, "Expected DEBUG information in stderr")
  end
end

