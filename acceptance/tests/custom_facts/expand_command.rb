test_name 'FACT-2054: Custom facts that execute a shell command should expand it' do
  tag 'risk:low'

confine :to, :platform => /el-7/

  content = <<-EOM
    Facter.add(:foo) do
      setcode do
        Facter::Core::Execution.execute("cd /opt/puppetlabs && pwd")
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

    step "Agent: Verify that command is expanded" do
      on(agent, facter('foo', :environment => env)) do |facter_result|
        refute_equal('/opt/puppetlabs', facter_result.stdout.chomp, 'command was not expanded')
      end
    end
  end
end