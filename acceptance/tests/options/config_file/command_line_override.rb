test_name "flags set on the command line override config file settings"
#
# This test is intended to demonstrate that all command-line flags take precedence
# over their counterparts in the config file. This only applies to exact repeats;
# if a command-line flag conflicts with a config file setting, a warning will be
# issued the same as if the user had specified two conflicting flags on the command
# line.
#
config = <<EOM
global : {
    external-dir : "config/file/dir"
}
cli : {
    debug : false
}
EOM

agents.each do |agent|
  step "Agent #{agent}: create config file"
  config_dir = agent.tmpdir("config_dir")
  config_file = File.join(config_dir, "facter.conf")
  create_remote_file(agent, config_file, config)

  step "--debug flag should override debug=false in config file"
  on(agent, facter("--config '#{config_file}' --debug")) do
    assert_match(/DEBUG/, stderr, "Expected DEBUG information in stderr")
  end

  step "--external_dir flag should override external_dir in config file"
  on(agent, facter("--config '#{config_file}' --external-dir 'cmd/line/dir'")) do
    assert_match(/cmd\/line\/dir/, stderr, "Facter should attempt to find external fact dir 'cmd/line/dir'")
    assert_no_match(/config\/file\/dir/, stderr, "Facter should not attempt to find external fact dir 'config/file/dir'")
  end

  step "conflict logic applies across settings sources"
  on(agent, facter("--config '#{config_file}' --no-external-facts"), :acceptable_exit_codes => [1]) do
    assert_match(/no-external-facts and external-dir options conflict/, stderr, "Facter should have warned about conflicting settings")
  end
end
