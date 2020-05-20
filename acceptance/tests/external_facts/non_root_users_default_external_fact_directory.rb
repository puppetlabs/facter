# verify that facter run as a non-root user honor facts in the users home directory:
# ~/.facter/facts.d
# ~/.puppetlabs/opt/facter/facts.d
test_name "C64580: Non-root default user external facts directory is searched for facts" do
  tag 'risk:high'

  confine :except, :platform => 'aix' # bug FACT-1586

  confine :except, :platform => 'windows' # this test currently only supported on unix systems FACT-1647
  confine :except, :platform => 'osx' # does not support managehome
  confine :except, :platform => 'solaris' # does not work with managehome on solaris boxes
  confine :except, :platform => 'eos-' # does not support user creation ARISTA-37

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  # Generate an external fact dynamically
  def ext_user_fact(value='BASIC')
    "test: '#{value}'"
  end

  # Retrieve a specific user's home directory $HOME/.facter
  #
  def get_user_facter_dir(user_home, platform)
    File.join(user_home, '.facter')
  end

  # Retrieve a specific user's home facts directory $HOME/.facter/facts.d
  #
  def get_user_facts_dir(user_home, platform)
    File.join(get_user_facter_dir(user_home, platform), 'facts.d')
  end

  # Retreive a specific user's home puppetlabs directory $HOME/.puppetlabs
  #
  def get_user_puppetlabs_dir(user_home, platform)
    File.join(user_home, '.puppetlabs')
  end

  # Retreive a specific user's home puppetlabs facts directory $HOME/.puppetlabs/opt/facter/facts.d
  #
  def get_user_puppetlabs_facts_dir(user_home, platform)
    File.join(get_user_puppetlabs_dir(user_home, platform), 'opt', 'facter', 'facts.d')
  end

  # retrieve the user's home directory for a host and user
  #
  def get_home_dir(host, user_name)
    home_dir = nil
    on host, puppet_resource('user', user_name) do |result|
      home_dir = result.stdout.match(/home\s*=>\s*'([^']+)'/m)[1]
    end
    home_dir
  end

  agents.each do |agent|
    non_root_user = "nonroot"

    step "Agent #{agent}: create a #{non_root_user} to run facter with" do
      on(agent, "puppet resource user #{non_root_user} ensure=present managehome=true shell='#{user_shell(agent)}'")
    end

    user_home = get_home_dir(agent, non_root_user)

    # The directories that facter processes facts for a user from
    user_base_facts_dir = get_user_facter_dir(user_home, agent['platform'])
    user_facts_dir = get_user_facts_dir(user_home, agent['platform'])
    user_facts_path = "#{user_facts_dir}/test.yaml"

    user_base_puppetlabs_dir = get_user_puppetlabs_dir(user_home, agent['platform'])
    user_puppetlabs_facts_dir = get_user_puppetlabs_facts_dir(user_home, agent['platform'])
    user_puppetlabs_facts_path = "#{user_puppetlabs_facts_dir}/test.yaml"

    step "Agent #{agent}: figure out facter program location"
    facter_path = agent.which('facter').chomp

    teardown do
      on(agent, "rm -rf '#{user_base_facts_dir}' '#{user_base_puppetlabs_dir}'")
      on(agent, puppet("resource user #{non_root_user} ensure=absent managehome=true"))
    end

    step "Agent #{agent}: create facts directory (#{user_facts_dir})" do
      on(agent, "rm -rf '#{user_facts_dir}'")
      on(agent, "mkdir -p '#{user_facts_dir}'")
    end

    step "Agent #{agent}: create and resolve a custom fact in #{user_facts_dir}" do
      create_remote_file(agent, user_facts_path, ext_user_fact('USER_TEST_FACTER'))
    end

    step "Agent #{agent}: chown and chmod the facts to the user #{non_root_user}" do
      on(agent, "chown -R #{non_root_user} '#{user_base_facts_dir}'")
      on(agent, "chmod -R a+rx '#{user_base_facts_dir}'")
    end

    step "Agent #{agent}: run facter as #{non_root_user} and make sure we get the fact" do
      on(agent, %Q[su #{non_root_user} -c "'#{facter_path}' test"]) do |facter_result|
        assert_match(/USER_TEST_FACTER/, facter_result.stdout, "Fact from #{user_facts_dir} did not resolve correctly")
      end
    end

    step "Agent #{agent}: remove #{user_facts_path}" do
      on(agent, "rm -rf '#{user_facts_path}'")
    end

    step "Agent #{agent}: create facts directory (#{user_puppetlabs_facts_dir})" do
      on(agent, "rm -rf '#{user_puppetlabs_facts_dir}'")
      on(agent, "mkdir -p '#{user_puppetlabs_facts_dir}'")
    end

    step "Agent #{agent}: create and resolve a custom fact in #{user_puppetlabs_facts_dir}" do
      create_remote_file(agent, user_puppetlabs_facts_path, ext_user_fact('USER_TEST_PUPPETLABS'))
    end

    step "Agent #{agent}: chown and chmod the facts to the user #{non_root_user}" do
      on(agent, "chown -R #{non_root_user} '#{user_base_puppetlabs_dir}'")
      on(agent, "chmod -R a+rx '#{user_base_puppetlabs_dir}'")
    end

    step "Agent #{agent}: run facter as #{non_root_user} and make sure we get the fact" do
      on(agent, %Q[su #{non_root_user} -c "'#{facter_path}' test"]) do |facter_result|
        assert_match(/USER_TEST_PUPPETLABS/, facter_result.stdout, "Fact from #{user_puppetlabs_facts_dir} did not resolve correctly")
      end
    end

    step "Agent #{agent}: create and resolve a custom fact in #{user_puppetlabs_facts_dir}" do
      create_remote_file(agent, user_facts_path, ext_user_fact('USER_PRECEDENCE_FACTER'))
      create_remote_file(agent, user_puppetlabs_facts_path, ext_user_fact('USER_PRECEDENCE_PUPPETLABS'))
    end

    step "Agent #{agent}: chown and chmod the facts to the user #{non_root_user}" do
      on(agent, "chown -R #{non_root_user} '#{user_base_facts_dir}' '#{user_base_puppetlabs_dir}'")
      on(agent, "chmod -R a+rx '#{user_base_facts_dir}' '#{user_base_puppetlabs_dir}'")
    end

    step "Agent #{agent}: run facter as #{non_root_user} and .facter will take precedence over .puppetlabs" do
      on(agent, %Q[su #{non_root_user} -c "'#{facter_path}' test"]) do |facter_result|
        assert_match(/USER_PRECEDENCE_FACTER/, facter_result.stdout, "Fact from #{user_puppetlabs_facts_dir} did not resolve correctly")
      end
    end
  end
end
