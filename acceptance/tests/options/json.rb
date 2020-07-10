# This test is intended to ensure that the --json command-line option works
# properly. This option causes Facter to output facts in JSON format.
# A custom fact is used to test for parity between Facter's output and
# the expected JSON output.
test_name "C99966, C98083: --json command-line option results in valid JSON output" do

  require 'json'
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  content = <<EOM
Facter.add('structured_fact') do
  setcode do
    { "foo" => {"nested" => "value1"}, "bar" => "value2", "baz" => "value3", "true" => true, "false" => false }
  end
end
EOM

  agents.each do |agent|
    step "Agent #{agent}: create a structured custom fact" do
      custom_dir = get_user_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      custom_fact = File.join(custom_dir, 'custom_fact.rb')
      on(agent, "mkdir -p '#{custom_dir}'")
      create_remote_file(agent, custom_fact, content)
      on(agent, "chmod +x '#{custom_fact}'")

      teardown do
        on(agent, "rm -f '#{custom_fact}'")
      end

      step "Agent #{agent}: retrieve output using the --json option" do
        on(agent, facter("--custom-dir '#{custom_dir}' --json structured_fact")) do
          begin
            expected = {"structured_fact" => {"foo" => {"nested" => "value1"}, "bar" => "value2", "baz" => "value3", "true" => true, "false" => false}}
            assert_equal(expected, JSON.parse(stdout.chomp), "JSON output does not match expected output")
          rescue
            fail_test "Couldn't parse output as JSON"
          end
        end
      end
    end
  end
end
