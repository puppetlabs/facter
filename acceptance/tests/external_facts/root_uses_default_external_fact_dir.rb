test_name "Root default external facts directory (facts.d) is searched for facts"

require 'facter/acceptance/user_fact_utils'
extend Facter::Acceptance::UserFactUtils

#
# This test is intended to ensure that executable external facts placed into the
# default facts.d directory are properly found and resolved by Facter when run
# as root.
#

unix_content = <<EOM
#!/bin/sh
echo "external_fact=testvalue"
EOM

win_content = <<EOM
@echo off
echo external_fact=testvalue
EOM

agents.each do |agent|
  os_version = on(agent, facter('kernelmajversion')).stdout.chomp.to_f
  factsd = get_factsd_dir(agent['platform'], os_version)
  ext = get_external_fact_script_extension(agent['platform'])

  if agent['platform'] =~ /windows/
    content = win_content
  else
    content = unix_content
  end

  step "Agent #{agent}: setup default external facts directory (facts.d)"
  on(agent, "mkdir -p '#{factsd}'")

  step "Agent #{agent}: create an executable external fact in default facts.d"
  ext_fact = File.join(factsd, "external_fact#{ext}")
  create_remote_file(agent, ext_fact, content)
  on(agent, "chmod +x '#{ext_fact}'")

  teardown do
    on(agent, "rm -f '#{ext_fact}'")
  end

  step "Agent #{agent}: the external fact should resolve"
  assert_equal("testvalue", fact_on(agent, "external_fact"))
end
