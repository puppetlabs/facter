test_name "ticket 1123  facter should not crash with invalid locale setting"
confine :except, :platform => 'windows'
agents.each do |host|
  step "set an invalid value for locale and run facter"
  result = on host, 'LANG=ABCD facter facterversion'
  fail_test "facter did not warn about the locale " unless
    result.stderr.include? 'WARN'
end

