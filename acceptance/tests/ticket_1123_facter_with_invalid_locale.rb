test_name 'ticket 1123  facter should not crash with invalid locale setting'
confine :except, :platform => 'windows'
confine :except, :platform => 'cisco-5'

agents.each do |host|
  step 'set an invalid value for locale and run facter'
  result = on host, 'LANG=ABCD facter facterversion'
  if host['platform'] !~ /solaris|aix|cumulus/
    fail_test 'facter did not warn about the locale' unless
      result.stderr.include? 'locale environment variables were bad; continuing with LANG=C'
  end
  fail_test 'facter did not continue running' unless
    result.stdout =~ /^\d+\.\d+\.\d+$/
end

