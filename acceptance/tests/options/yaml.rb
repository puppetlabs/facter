test_name "--yaml command-line option results in valid YAML output"

require 'yaml'
require 'facter/acceptance/user_fact_utils'
extend Facter::Acceptance::UserFactUtils

#
# This test is intended to ensure that the --yaml command-line option works
# properly. This option causes Facter to output facts in YAML format.
# A custom fact is used to test for parity between Facter's output and
# the expected YAML output.
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

  step "Agent #{agent}: retrieve output using the --yaml option"
  on(agent, facter("--custom-dir '#{custom_dir}' --yaml structured_fact")) do
    begin
      expected = {"structured_fact" => {"foo" => {"nested" => "value1"}, "bar" => "value2", "baz" => "value3" }}.to_yaml.gsub("---\n", '')
      assert_equal(expected, stdout, "YAML output does not match expected output")
    rescue
      fail_test "Couldn't parse output as YAML"
    end
  end
end
