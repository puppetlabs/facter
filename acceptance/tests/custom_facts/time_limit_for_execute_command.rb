test_name 'Facter::Core::Execution accepts and correctly sets a time limit option' do
  tag 'risk:high'

  first_file_content = <<-EOM
    Facter.add(:foo) do
      setcode do
        Facter::Core::Execution.execute("sleep 3", {:limit => 2})
      end
    end
  EOM

  second_file_content = <<-EOM
    Facter.add(:custom_fact) do
      setcode do
         Facter::Core::Execution.execute("sleep 2")
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
      on agent, facter('--custom-dir', custom_dir, 'foo --debug') do |facter_output|
        assert_match(/DEBUG Facter::Core::Execution.* - Timeout encounter after 2s, killing process with pid:/,
                     facter_output.stderr.chomp)
      end
    end

    step "Facter: Logs that command of the second custom fact had timeout after befault time limit" do
      on agent, facter('--custom-dir', custom_dir, 'custom_fact --debug') do |facter_output|
        assert_match(/DEBUG Facter::Core::Execution.* - Timeout encounter after 1.5s, killing process with pid:/,
                     facter_output.stderr.chomp)
      end
    end
  end
end
