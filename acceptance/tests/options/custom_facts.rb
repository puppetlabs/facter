test_name "custom fact commandline options (--no-custom-facts and --custom-dir)"

require 'facter/acceptance/user_fact_utils'
extend Facter::Acceptance::UserFactUtils

#
# These tests are intended to ensure both custom fact related command-line options
# work properly. The first step tests that an existing custom fact in Facter's
# custom fact load path will not execute when the `--no-custom-facts` option is passed.
# The second step checks that a custom fact in a directory specified by the `--custom-dir`
# option is found by Facter and resolved.
#

content = <<EOM
Facter.add('custom_fact') do
  setcode do
    "testvalue"
  end
end
EOM

agents.each do |agent|

  custom_dir = get_user_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

  step "Agent #{agent}: create custom fact directory and executable custom fact"
  on(agent, "mkdir -p '#{custom_dir}'")
  custom_fact = File.join(custom_dir, 'custom_fact.rb')
  create_remote_file(agent, custom_fact, content)
  on(agent, "chmod +x '#{custom_fact}'")

  teardown do
    on(agent, "rm -f '#{custom_fact}'")
  end

  step "--no-custom-facts option should disable custom facts"
  on(agent, facter("--no-custom-facts custom_fact")) do
    assert_equal("", stdout.chomp, "Expected custom fact to be disabled, but it resolved as #{stdout.chomp}")
  end

  step "--custom-dir option should allow custom facts to be resolved from a specific directory"
  on(agent, facter("--custom-dir '#{custom_dir}' custom_fact")) do
    assert_equal("testvalue", stdout.chomp, "Custom fact output does not match expected output")
  end
end
