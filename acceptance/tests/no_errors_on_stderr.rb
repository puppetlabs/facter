test_name 'C14514: Running facter should not output anything to stderr' do
  tag 'risk:high'

  agents.each do |agent|
    on(agent, facter(@options[:trace])) do |facter_output|
      assert_match(/hostname\s*=>\s*\S*/, facter_output.stdout, 'Hostname fact is missing')
      assert_empty(facter_output.stderr, 'Facter should not have written to stderr')
    end
  end
end
