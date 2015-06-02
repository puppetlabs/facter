test_name "--json command-line option results in valid JSON output"

require 'json'
require 'facter/acceptance/user_fact_utils'
extend Facter::Acceptance::UserFactUtils

#
# This test is intended to ensure that the --json command-line option works
# properly. This option causes Facter to output facts in JSON format.
# A custom fact is used to test for parity between Facter's output and
# the expected JSON output.
#

content = <<EOM
Facter.add('structured_fact') do
  setcode do
    { "foo" => {"nested" => "value1"}, "bar" => "value2", "baz" => "value3" }
  end
end
EOM

agents.each do |agent|
  custom_dir = get_user_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

  step "Agent #{agent}: create a structured custom fact"
  custom_fact = File.join(custom_dir, 'custom_fact.rb')
  on(agent, "mkdir -p '#{custom_dir}'")
  create_remote_file(agent, custom_fact, content)
  on(agent, "chmod +x '#{custom_fact}'")

  teardown do
    on(agent, "rm -f '#{custom_fact}'")
  end

  step "Agent #{agent}: retrieve output using the --json option"
  on(agent, facter("--custom-dir '#{custom_dir}' --json structured_fact")) do
    begin
      expected = JSON.pretty_generate({"structured_fact" => {"foo" => {"nested" => "value1"}, "bar" => "value2", "baz" => "value3"}})
      assert_equal(expected, stdout.chomp, "JSON output does not match expected output")
    rescue
      fail_test "Couldn't parse output as JSON"
    end
  end
end
