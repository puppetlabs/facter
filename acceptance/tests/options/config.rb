# This test is intended to verify that the config file location can be specified
# via the `--config` flag on the command line.
test_name "C100014: --config command-line option designates the location of the config file" do
  tag 'risk:high'

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      create_remote_file(agent, config_file, <<-FILE)
      cli : {
          debug : true
      }
      FILE

      teardown do
        agent.rm_rf(config_dir)
      end

      step "setting --config should cause the config file to be loaded from the specified location" do
        on(agent, facter("--config \"#{config_file}\"")) do |facter_output|
          assert_match(/DEBUG/, facter_output.stderr, "Expected debug output on stderr")
        end
      end
    end
  end
end
