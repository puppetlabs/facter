# This test is intended to demonstrate that the global.external-dir config file setting allows
# a directory to be specified for external fact lookup. It also shows that the global.no-external-facts 
# setting disables external fact lookup.
test_name "external-dir and no-external-facts config fields allow control of external fact lookup" do
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  unix_content = <<EOM
#!/bin/sh
echo "external_fact=testvalue"
EOM

  windows_content = <<EOM
@echo off
echo external_fact=testvalue
EOM

  agents.each do |agent|
    os_version = on(agent, facter('kernalmajversion')).stdout.chomp.to_f
    factsd = get_factsd_dir(agent['platform'], os_version)
    custom_external_dir = get_user_fact_dir(agent['platform'], os_version)
    ext = get_external_fact_script_extension(agent['platform'])

    if agent['platform'] =~ /windows/
      content = windows_content
    else
      content = unix_content
    end

    step "Agent #{agent}: set up facts.d, custom external fact directories, and config file" do
      on(agent, "mkdir -p '#{factsd}'")
      on(agent, "mkdir -p '#{custom_external_dir}'")
      ext_fact_factsd     = File.join(factsd, "external_fact#{ext}")
      ext_fact_custom_dir = File.join(custom_external_dir, "external_fact#{ext}")
      create_remote_file(agent, ext_fact_factsd, content)
      create_remote_file(agent, ext_fact_custom_dir, content)
      on(agent, "chmod +x '#{ext_fact_factsd}' '#{ext_fact_custom_dir}'")

      teardown do
        on(agent, "rm -f '#{ext_fact_factsd}' '#{ext_fact_custom_dir}'")
      end

      config_no_ext = <<EOM
global : {
    no-external-facts : true
}
cli : {
    debug : true
}
EOM

      config_dir = agent.tmpdir("config_dir")
      config_no_ext_file = File.join(config_dir, "no_ext.conf")
      create_remote_file(agent, config_no_ext_file, config_no_ext)

      config_ext = <<EOM
global : {
    external-dir : "#{ext_fact_custom_dir}"
}
cli : {
    debug : true
}
EOM

      config_ext_file = File.join(config_dir, "ext.conf")
      create_remote_file(agent, config_ext_file, config_ext)

      step "setting no-external-facts to true should disable external facts" do
        on(agent, facter("--config '#{config_no_ext_file}' external_fact")) do
          assert_equal("", stdout.chomp, "Expected external fact to be disabled, but it resolved as #{stdout.chomp}")
        end
      end

      step "setting external-dir should specify location of external facts" do
        on(agent, facter("--config '#{config_ext_file}' external_fact")) do
          assert_equal("testvalue", stdout.chomp, "External fact output does not match expected output")
        end
      end
    end
  end
end

