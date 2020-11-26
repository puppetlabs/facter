test_name 'Facter::Core::Execution accepts and correctly sets a time limit option' do
  tag 'risk:high'

  first_file_content = <<-EOM
    Facter.add(:foo) do
      setcode do
        Facter::Core::Execution.execute("sleep 3", {:limit => 2, :on_fail => :not_raise})
      end
    end
  EOM

  second_file_content = <<-EOM
    Facter.add(:custom_fact) do
      setcode do
         Facter::Core::Execution.execute("sleep 2", {:limit => 1})
      end
    end
  EOM


  agents.each do |agent|

    custom_dir = agent.tmpdir('arbitrary_dir')
    fact_file1 = File.join(custom_dir, 'file1.rb')
    fact_file2 = File.join(custom_dir, 'file2.rb')
    create_remote_file(agent, fact_file1, first_file_content)
    create_remote_file(agent, fact_file2, second_file_content)

    teardown do
      agent.rm_rf(custom_dir)
    end

    step "Facter: Logs that command of the first custom fact had timeout after setted time limit" do
      on agent, facter('--custom-dir', custom_dir, "foo --debug #{@options[:trace]}") do |output|
        assert_match(/DEBUG Facter::Core::Execution.*Timeout encounter after 2s, killing process with pid:/,
                     output.stderr.chomp)
      end
    end

    step "Facter: Logs an error stating that the command of the second custom fact had timeout" do
      on(agent, facter('--custom-dir', custom_dir, "custom_fact --debug #{@options[:trace]}"),
         acceptable_exit_codes: 1) do |output|
        assert_match(/ERROR\s+.*Failed while executing '.*sleep.*2': Timeout encounter after 1s, killing process/,
                     output.stderr.chomp)
      end
    end
  end
end
