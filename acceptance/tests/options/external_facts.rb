test_name "external fact commandline options (--no-external-facts and --external-dir)"

require 'facter/acceptance/user_fact_utils'
extend Facter::Acceptance::UserFactUtils

#
# These tests are intended to ensure both external fact related command-line options
# work properly. The first step tests that an existing external fact in the standard
# facts.d directory will not execute when the `--no-external-facts` option is passed.
# The second step checks that an external step in a directory specified by the 
# `--external-dir` option is found by Facter and resolved.
#

unix_content = <<EOM
#!/bin/sh
echo "external_fact=testvalue"
EOM

win_content = <<EOM
echo "external_fact=testvalue"
EOM

agents.each do |agent|
  os_version = on(agent, facter('kernelmajversion')).stdout.chomp.to_f
  factsd = get_factsd_dir(agent['platform'], os_version)
  custom_external_dir = get_user_fact_dir(agent['platform'], os_version)
  ext = get_external_fact_script_extension(agent['platform'])

  if agent['platform'] =~ /windows/
    content = win_content
  else
    content = unix_content
  end

  step "Agent #{agent}: setup facts.d and custom external fact directories"
  on(agent, "mkdir -p '#{factsd}'")
  on(agent, "mkdir -p '#{custom_external_dir}'")

  step "Agent #{agent}: create executable external facts in facts.d and custom external fact dir"
  ext_fact_factsd     = "#{factsd}/external_fact#{ext}"
  ext_fact_custom_dir = "#{custom_external_dir}/external_fact#{ext}"
  create_remote_file(agent, ext_fact_factsd, content)
  create_remote_file(agent, ext_fact_custom_dir, content)
  on(agent, "chmod +x #{ext_fact_factsd} #{ext_fact_custom_dir}")

  teardown do
    on(agent, "rm -f '#{ext_fact_factsd} #{ext_fact_custom_dir}'")
  end

  step "--no-external-facts option should disable external facts"
  on(agent, "facter --no-external-facts external_fact") do
    assert_equal("", stdout.chomp, "Expected external fact to be disabled, but it resolved as #{stdout.chomp}")
  end

  step "--external-dir option should allow external facts to be resolved from a specific directory"
  on(agent, "facter --external-dir #{custom_external_dir} external_fact") do
    assert_equal("testvalue", stdout.chomp, "External fact output does not match expected output")
  end
end
