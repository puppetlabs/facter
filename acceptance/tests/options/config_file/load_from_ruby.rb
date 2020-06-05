# This test is intended to demonstrate that Facter's config file will
# load correctly from the default location when Facter is required from Ruby.
# On *nix, this location is /etc/puppetlabs/facter/facter.conf.
# On Windows, it is C:\ProgramData\PuppetLabs\facter\etc\facter.conf
#
# The test also verifies that facter will search for external facts and custom facts
# in the directory paths defined with external-dir and custom-dir in the facter.conf file
test_name "C98141: config file is loaded when Facter is run from Puppet" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    # create paths for default facter.conf, external-dir, and custom-dir

    # default facter.conf
    facter_conf_default_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    facter_conf_default_path = File.join(facter_conf_default_dir, "facter.conf")

    # external-dir
    ext_fact_dir1 = agent.tmpdir('ext_fact_dir1')
    ext_path1     = File.join(ext_fact_dir1, "test_ext_fact1.yaml")
    ext_fact_dir2 = agent.tmpdir('ext_fact_dir2')
    ext_path2     = File.join(ext_fact_dir2, "test_ext_fact2.yaml")

    # custom-dir
    cust_fact_dir = agent.tmpdir('custom_fact_dir')
    cust_path     = File.join(cust_fact_dir, "custom_fact.rb")

    teardown do
      agent.rm_rf(facter_conf_default_dir)
      agent.rm_rf(ext_fact_dir1)
      agent.rm_rf(ext_fact_dir2)
      agent.rm_rf(cust_fact_dir)
    end

    # create the directories
    [facter_conf_default_dir, ext_fact_dir1, ext_fact_dir2, cust_fact_dir].each do |dir|
      agent.mkdir_p(dir)
    end

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

    step "running `puppet facts` should load the config file automatically and search all external-dir and custom-dir paths" do
      on(agent, puppet('facts')) do |puppet_facts_output|
        assert_match(/This is external fact 1 in #{ext_fact_dir1} directory/, puppet_facts_output.stdout, "Expected external fact")
        assert_match(/This is external fact 2 in #{ext_fact_dir2} directory/, puppet_facts_output.stdout, "Expected external fact")
        assert_match(/This is a custom fact in #{cust_fact_dir} directory/, puppet_facts_output.stdout, "Expected custom fact")
      end
    end
  end
end
