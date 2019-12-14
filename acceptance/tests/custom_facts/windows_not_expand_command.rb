test_name 'FACT-2054: Execute on Windows with expand => false should raise an error' do
  tag 'risk:low'

  confine :to, :platform => /windows/

  content = <<-EOM
    Facter.add(:foo) do
      setcode do
        Facter::Core::Execution.execute("cmd", {:expand => false})
      end
    end
  EOM

  agents.each do |agent|
    fact_dir = agent.tmpdir('facter')
    fact_file = File.join(fact_dir, 'test_facts.rb')
    create_remote_file(agent, fact_file, content)
    env = {'FACTERLIB' => fact_dir}

    teardown do
      on(agent, "rm -rf '#{fact_dir}'")
    end

    step "Agent: Verify that exception is raised" do
      on(agent, facter('foo', :environment => env), :acceptable_exit_codes => [0, 1]) do |output|
        assert_match(/Unsupported argument on Windows/, output.stderr, '{:expand => false} on Windows should raise error')
      end
    end
  end
end
