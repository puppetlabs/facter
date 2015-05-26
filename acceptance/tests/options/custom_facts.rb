test_name "custom fact commandline options (--no-custom-facts and --custom-dir)"

require 'puppet/acceptance/common_utils'
extend Puppet::Acceptance::CommandUtils

require 'facter/acceptance/user_fact_utils'
extend Facter::Acceptance::UserFactUtils

#
# These tests are intended to ensure both custom fact related command-line options
# work properly. The first step tests that an existing custom fact in Facter's
# custom fact load path will not execute when the `--no-custom-facts` option is passed.
# The second step checks that a custom fact in a directory specified by the `--custom-dir`
# option is found by Facter and resolved.
#
# The second set of tests are intended to ensure that custom facts located in FACTERLIB
# or $LOAD_PATH directories are resolved.
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

  step "Agent #{agent}: create custom fact directory and custom fact"
  on(agent, "mkdir -p '#{custom_dir}'")
  custom_fact = File.join(custom_dir, 'custom_fact.rb')
  create_remote_file(agent, custom_fact, content)


  step "--no-custom-facts option should disable custom facts"
  on(agent, facter("--no-custom-facts custom_fact")) do
    assert_equal("", stdout.chomp, "Expected custom fact to be disabled, but it resolved as #{stdout.chomp}")
  end

  step "--custom-dir option should allow custom facts to be resolved from a specific directory"
  on(agent, facter("--custom-dir '#{custom_dir}' custom_fact")) do
    assert_equal("testvalue", stdout.chomp, "Custom fact output does not match expected output")
  end

  on(agent, "rm -f '#{custom_fact}'")

  step "Agent #{agent}: ensure custom facts in $FACTERLIB resolve"
  facterlib_dir = agent.tmpdir('arbitrary_dir')
  custom_fact = File.join(facterlib_dir, 'custom_fact.rb')
  create_remote_file(agent, custom_fact, content)

  on(agent, facter('custom_fact', :environment => { 'FACTERLIB' => facterlib_dir })) do
    assert_equal("testvalue", stdout.chomp, "Output from custom fact in FACTERLIB does not match expected outout")
  end

  on(agent, "rm -rf '#{facterlib_dir}'")

  step "Agent #{agent}: ensure custom facts in $LOAD_PATH resolve"
  on(agent, "#{ruby_command(agent)} -e 'puts $LOAD_PATH[0]'")
  load_path_facter_dir = File.join(stdout.chomp, 'facter')
  on(agent, "mkdir -p \"#{load_path_facter_dir}\"")
  custom_fact = File.join(load_path_facter_dir, 'custom_fact.rb')
  create_remote_file(agent, custom_fact, content)

  on(agent, facter("custom_fact")) do
    assert_equal("testvalue", stdout.chomp, "Output from custom fact in $LOAD_PATH does not match expected output")
  end

  on(agent, "rm -rf '#{load_path_facter_dir}'")
end
