test_name 'C100160: facter exits with success when asked for a non-existent fact' do
  tag 'risk:high'

  agents.each do |agent|
    step 'facter should return exit code 0 for querying non-existing-fact without --strict flag' do
      on(agent, facter('non-existing-fact'), :acceptable_exit_codes => 0)
    end
  end
end
