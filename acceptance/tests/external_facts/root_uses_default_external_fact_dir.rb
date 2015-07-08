test_name "Root default external facts directory (facts.d) is searched for facts"

require 'facter/acceptance/user_fact_utils'
extend Facter::Acceptance::UserFactUtils

#
# The first of these tests is intended to ensure that executable external facts placed into the
# default facts.d directory are properly found and resolved by Facter when run as root.
# The second ensures that when Facter is given a user specified external fact directory, facts
# from both it and the default facts.d directory are resolved. Finally, we test that given
# conflicting external facts in a user specified directory and the default facts.d directory,
# the user specified fact wins.
#

unix_fact_1_content = <<EOM
#!/bin/sh
echo "external_fact_1=foo"
EOM

unix_override_content = <<EOM
#!/bin/sh
echo "external_fact_1=baz"
EOM

unix_fact_2_content = <<EOM
#!/bin/sh
echo "external_fact_2=bar"
EOM

win_fact_1_content = <<EOM
@echo off
echo external_fact_1=foo
EOM

win_override_content = <<EOM
@echo off
echo external_fact_1=baz
EOM

win_fact_2_content = <<EOM
@echo off
echo external_fact_2=bar
EOM

agents.each do |agent|
  os_version = on(agent, facter('kernelmajversion')).stdout.chomp.to_f
  factsd = get_factsd_dir(agent['platform'], os_version)
  custom_external_dir = get_user_fact_dir(agent['platform'], os_version)
  ext = get_external_fact_script_extension(agent['platform'])

  if agent['platform'] =~ /windows/
    content_1 = win_fact_1_content
    content_2 = win_fact_2_content
    override_content = win_override_content
  else
    content_1 = unix_fact_1_content
    content_2 = unix_fact_2_content
    override_content = unix_override_content
  end

  step "Agent #{agent}: setup default external facts directory (facts.d)"
  on(agent, "mkdir -p '#{factsd}'")

  step "Agent #{agent}: create an executable external fact in default facts.d"
  ext_fact_1 = File.join(factsd, "external_fact_1#{ext}")
  create_remote_file(agent, ext_fact_1, content_1)
  on(agent, "chmod +x '#{ext_fact_1}'")

  step "Agent #{agent}: the external fact should resolve"
  assert_equal("foo", fact_on(agent, "external_fact_1"))

  step "Ensure that Facter honors default facts.d dir in addition to user specified directories"
  on(agent, "mkdir -p '#{custom_external_dir}'")
  ext_fact_2 = File.join(custom_external_dir, "external_fact_2#{ext}")
  create_remote_file(agent, ext_fact_2, content_2)
  on(agent, "chmod +x '#{ext_fact_2}'")

  step "Agent #{agent}: both external facts should resolve"
  on(agent, facter("--external-dir '#{custom_external_dir}' external_fact_1 external_fact_2"))
  assert_match(/external_fact_1 => foo/, stdout)
  assert_match(/external_fact_2 => bar/, stdout)

  step "Ensure that facts in the default external fact dir are overridden by facts in specified dirs"
  ext_fact_3 = File.join(custom_external_dir, "external_fact_3#{ext}")
  create_remote_file(agent, ext_fact_3, override_content)
  on(agent, "chmod +x '#{ext_fact_3}'")

  step "Agent #{agent}: the fact value from the custom external dir should override that of facts.d"
  on(agent, facter("--external-dir '#{custom_external_dir}' external_fact_1"))
  assert_match(/baz/, stdout)

  teardown do
    on(agent, "rm -f '#{ext_fact_1}' '#{ext_fact_2}' '#{ext_fact_3}'")
  end
end
