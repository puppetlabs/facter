# This test is intended to demonstrate that Facter will load a config file
# saved at the default location without any special command line flags.
# On *nix, this location is /etc/puppetlabs/facter/facter.conf.
# On Windows 6.0 or newer, it is C:\ProgramData\PuppetLabs\facter\facter.conf
# On Windows older than 6.0, it is
# C:\Documents and Settings\All Users\Application Data\PuppetLabs\facter\facter.conf
#
# The test also verifies that facter will search for external facts and custom facts
# in the directory paths defined with external-dir and custome-dir in the facter.conf file
test_name "FACT-1494 - C98142 Load facter.conf having external-dir" do
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    # creat paths for default facter.conf, external-dir, and custom-dir
    #

    # defaul facter.conf
    facter_conf_default_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    facter_conf_default_path = "#{facter_conf_default_dir}/facter.conf"

    # external-dir
    ext_fact_dir1 = agent.tmpdir('ext_fact_dir1')
    ext_path1     = "#{ext_fact_dir1}/test_ext_fact1.yaml"
    ext_fact_dir2 = agent.tmpdir('ext_fact_dir2')
    ext_path2     = "#{ext_fact_dir2}/test_ext_fact2.yaml"

    # custom-dir
    cust_fact_dir = agent.tmpdir('cust_fact_dir')
    cust_path     = "#{cust_fact_dir}/custom_fact.rb"

    # create the directories
    on(agent, "mkdir -p '#{facter_conf_default_dir}' '#{ext_fact_dir1}' '#{ext_fact_dir2}' '#{cust_fact_dir}'")

    step "Agent #{agent}: create facter.conf, external fact, and custom fact files" do

      create_remote_file(agent, facter_conf_default_path, <<-FILE)
        global : {
          external-dir : ["#{ext_fact_dir1}", "#{ext_fact_dir2}"],
          custom-dir : ["#{cust_fact_dir}"]
      }
      FILE

      create_remote_file(agent, ext_path1, <<-FILE)
        externalfact1: 'This is external fact 1 in #{ext_fact_dir1} directory'
      FILE

      create_remote_file(agent, ext_path2, <<-FILE)
        externalfact2: 'This is external fact 2 in #{ext_fact_dir2} directory'
      FILE

      create_remote_file(agent, cust_path, <<-FILE)
        Facter.add('customfact') do
          setcode do
            'This is a custom fact in #{cust_fact_dir} directory'
          end
        end
      FILE
    end

    step "config file should be loaded automatically and search all external-dir and custome-dir paths" do
      on(agent, facter("")) do
        assert_match(/This is external fact 1 in #{ext_fact_dir1} directory/, stdout, "Expected external fact")
        assert_match(/This is external fact 2 in #{ext_fact_dir2} directory/, stdout, "Expected external fact")
        assert_match(/This is a custom fact in #{cust_fact_dir} directory/, stdout, "Expected custom fact")
      end
    end

    teardown do
      on(agent, "rm -rf '#{facter_conf_default_dir}' '#{ext_fact_dir1}' '#{ext_fact_dir2}' '#{cust_fact_dir}'")
    end
  end
end
