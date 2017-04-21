test_name 'C98098: --strict flag returns errors on non-existent facts' do
  tag 'risk:high'

  agents.each do |agent|
    step 'facter should return exit code 1 for querying non-existing-fact with --strict flag' do
      on(agent, facter('non-existing-fact --strict'), :acceptable_exit_codes => 1) do |facter_output|
        assert_match(/ERROR\s+.* - fact "non-existing-fact" does not exist/, facter_output.stderr, 'Unexpected error was detected!')
      end
    end
  end
end
