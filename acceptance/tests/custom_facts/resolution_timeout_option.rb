test_name "Facter::Util::Resolution accepts timeout option" do
  tag 'risk:high'

  file_content = <<-EOM
    Facter.add(:foo, {timeout: 0.2}) do
      setcode do
        Facter::Core::Execution.execute("sleep 1")
      end
    end
  EOM


  agents.each do |agent|

    custom_dir = agent.tmpdir('arbitrary_dir')
    fact_file = File.join(custom_dir, 'fact.rb')
    create_remote_file(agent, fact_file, file_content)

    teardown do
      agent.rm_rf(custom_dir)
    end

    step "Facter: Errors that the custom fact reached the timeout" do
      on(agent, facter("--custom-dir #{custom_dir} foo #{@options[:trace]}"), acceptable_exit_codes: 1) do |output|
        assert_match(/ERROR .*Timed out after 0.2 seconds while resolving fact='foo', resolution=.*/,
                     output.stderr.chomp)
      end
    end
  end
end

