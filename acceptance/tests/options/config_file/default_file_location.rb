# This test is intended to demonstrate that Facter will load a config file
# saved at the default location without any special command line flags.
# On Unix, this location is /etc/puppetlabs/facter/facter.conf.
# On Windows, it is C:\ProgramData\PuppetLabs\facter\etc\facter.conf
test_name "C99991: config file is loaded from default location" do
  tag 'risk:high'

  config = <<EOM
cli : {
    debug : true
}
EOM

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      if agent['platform'] =~ /windows/
        config_dir = 'C:\\ProgramData\\PuppetLabs\\facter\\etc'
        config_file = "#{config_dir}\\facter.conf"
     else
        config_dir = '/etc/puppetlabs/facter'
        config_file = "#{config_dir}/facter.conf"
      end

      agent.mkdir_p(config_dir)

      create_remote_file(agent, config_file, config)

      teardown do
        agent.rm_rf(config_dir)
      end

      step "config file should be loaded automatically and turn DEBUG output on" do
        on(agent, facter("")) do |facter_output|
          assert_match(/DEBUG/, facter_output.stderr, "Expected DEBUG information in stderr")
        end
      end
    end
  end
end
