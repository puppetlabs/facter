test_name "Facter::Core::Execution doesn't kill process with long stderr message" do
  tag 'risk:high'

  confine :except, :platform => /windows/

  long_output = "This is a very long error message. " * 4096
  file_content = <<-EOM
   #!/bin/sh
   echo 'newfact=value_of_fact'
   1>&2 echo #{long_output}
   exit 1
  EOM


  agents.each do |agent|

    external_dir = agent.tmpdir('external_dir')
    fact_file = File.join(external_dir, 'test.sh')
    create_remote_file(agent, fact_file, file_content)
    agent.chmod('+x', fact_file)

    teardown do
      agent.rm_rf(external_dir)
    end

    step "Facter: should resolve the external fact and print as warning script's stderr message" do
      on agent, facter('--external-dir', external_dir, 'newfact') do |facter_output|
        assert_match(/value_of_fact/, facter_output.stdout.chomp)
        assert_match(/WARN test.sh .*test.sh resulted with the following stderr message: This is a very long error message./, facter_output.stderr.chomp)
      end
    end
  end
end

