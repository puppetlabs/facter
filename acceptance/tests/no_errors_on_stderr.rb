test_name "Running facter should not output anything to stderr"

on(hosts, facter) do |result|
  fail_test "Hostname fact is missing" unless stdout =~ /hostname\s*=>\s*\S*/
  fail_test "Facter should not have written to stderr: #{stderr}" unless stderr == ""
end
