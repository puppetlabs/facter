test_name 'ticket FACT-1476 - C98098 facter cli with --strict flag'

agents.each do |host|
  step 'facter should return exit code 0 for querying non-existing-fact without --strict flag'
  on(host, facter('-p non-existing-fact'))

  step 'facter should return exit code 1 for querying non-existing-fact with --strict flag'
  on(host, facter('-p non-existing-fact --strict'), :acceptable_exit_codes => 1) do |result|
    assert_match(/ERROR\s+puppetlabs\.facter - fact "non-existing-fact" does not exist/, result.stderr, 'Unexpected error was detected!')
  end
end
