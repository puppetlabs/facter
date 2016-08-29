# This test is intended to demonstrate that Facter will load a config file
# saved at the default location without any special command line flags.
# On Unix, this location is /etc/puppetlabs/facter/facter.conf.
# On Windows, it is C:\ProgramData\PuppetLabs\facter\etc\facter.conf
test_name "config file is loaded from default location" do
  config = <<EOM
cli : {
    debug : true
}
EOM

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      if agent['platform'] =~ /windows/
        config_dir = 'C:\\ProgramData\\PuppetLabs\\facter\\etc'
     else
        config_dir = "/etc/puppetlabs/facter"
      end

      on(agent, "mkdir -p '#{config_dir}'")
      config_file = File.join(config_dir, "facter.conf")
      create_remote_file(agent, config_file, config)

      teardown do
        on(agent, "rm -rf '#{config_dir}'", :acceptable_exit_codes => [0,1])
      end

      step "config file should be loaded automatically and turn DEBUG output on" do
        on(agent, facter("")) do 
          assert_match(/DEBUG/, stderr, "Expected DEBUG information in stderr")
        end
      end
    end
  end
end
