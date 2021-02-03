test_name "(FACT-2934) Facter::Core::Execution sets $?" do
  tag 'risk:high'

  agents.each do |agent|
    command = if agent['platform'] =~/windows/
                'cmd /c exit 1'
              else
                `which false`.chomp
              end

    content = <<-EOM
    Facter.add(:foo) do
      setcode do
         Facter::Util::Resolution.exec('#{command}')
         "#{command} exited with code: %{status}" % {status: $?.exitstatus}
      end
    end
    EOM


    fact_dir = agent.tmpdir('facter')
    fact_file = File.join(fact_dir, 'test_facts.rb')
    create_remote_file(agent, fact_file, content)

    teardown do
      agent.rm_rf(fact_dir)
    end

    step "Facter: should resolve the custom fact" do
      on(agent, facter('--custom-dir', fact_dir, 'foo')) do |facter_output|
        assert_match(/exited with code: 1/, facter_output.stdout.chomp)
      end
    end
  end
end


