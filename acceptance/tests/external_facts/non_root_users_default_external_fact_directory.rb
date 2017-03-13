test_name "Non-root default user external facts directory is searched for facts" do

  confine :except, :platform => 'aix'     # bug FACT-1586

  confine :except, :platform => 'windows' # this test is for unix systems
  confine :except, :platform => 'osx'     # does not support managehome
  confine :except, :platform => 'solaris' # does not work with managehome on solaris boxes
  confine :except, :platform => 'eos-'    # does not support user creation ARISTA-37

  # TestRail: C64580

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

  # retrieve the correct shell path for system under test
  #
  def user_shell(agent)
    if agent['platform'] =~ /aix/
      '/usr/bin/bash'
    else
      '/bin/bash'
    end
  end

  agents.each do |agent|
    non_root_user = "nonroot"

    step "Agent #{agent}: create a #{non_root_user} to run facter with"
    on(agent, "puppet resource user #{non_root_user} ensure=present managehome=true shell='#{user_shell(agent)}'")

    user_home = get_home_dir(agent, non_root_user)

    # The directories that facter processes facts for a user from
    user_base_facts_dir = get_user_facter_dir(user_home, agent['platform'])
    user_facts_dir = get_user_facts_dir(user_home, agent['platform'])
    user_facts_path = "#{user_facts_dir}/test.yaml"

    user_base_puppetlabs_dir = get_user_puppetlabs_dir(user_home, agent['platform'])
    user_puppetlabs_facts_dir = get_user_puppetlabs_facts_dir(user_home, agent['platform'])
    user_puppetlabs_facts_path = "#{user_puppetlabs_facts_dir}/test.yaml"

    step "Agent #{agent}: figure out facter program location"
    facter_path = on(agent, "which facter").stdout.chomp

    teardown do
      on(agent, "rm -rf #{user_base_facts_dir} #{user_base_puppetlabs_dir}")
      on(agent, puppet("resource user #{non_root_user} ensure=absent managehome=true"))
    end

    step "Agent #{agent}: create facts directory (#{user_facts_dir})"
    on(agent, "rm -rf #{user_facts_dir}")
    on(agent, "mkdir -p #{user_facts_dir}")

    step "Agent #{agent}: create and resolve a custom fact in #{user_facts_dir}"
    create_remote_file(agent, user_facts_path, ext_user_fact('USER_TEST_FACTER'))

    step "Agent #{agent}: chown and chmod the facts to the user #{non_root_user}"
    on(agent, "chown -R #{non_root_user} #{user_base_facts_dir}")
    on(agent, "chmod -R a+rx #{user_base_facts_dir}")

    step "Agent #{agent}: run facter as #{non_root_user} and make sure we get the fact"
    on(agent, %Q[su #{non_root_user} -c "#{facter_path} test"]) do
      assert_match(/USER_TEST_FACTER/, stdout, "Fact from #{user_facts_dir} did not resolve correctly")
    end

    step "Agent #{agent}: remove #{user_facts_path}"
    on(agent, "rm -rf #{user_facts_path}")

    step "Agent #{agent}: create facts directory (#{user_puppetlabs_facts_dir})"
    on(agent, "rm -rf #{user_puppetlabs_facts_dir}")
    on(agent, "mkdir -p #{user_puppetlabs_facts_dir}")

    step "Agent #{agent}: create and resolve a custom fact in #{user_puppetlabs_facts_dir}"
    create_remote_file(agent, user_puppetlabs_facts_path, ext_user_fact('USER_TEST_PUPPETLABS'))

    step "Agent #{agent}: chown and chmod the facts to the user #{non_root_user}"
    on(agent, "chown -R #{non_root_user} #{user_base_puppetlabs_dir}")
    on(agent, "chmod -R a+rx #{user_base_puppetlabs_dir}")

    step "Agent #{agent}: run facter as #{non_root_user} and make sure we get the fact"
    on(agent, %Q[su #{non_root_user} -c "#{facter_path} test"]) do
      assert_match(/USER_TEST_PUPPETLABS/, stdout, "Fact from #{user_puppetlabs_facts_dir} did not resolve correctly")
    end

    step "Agent #{agent}: create and resolve a custom fact in #{user_puppetlabs_facts_dir}"
    create_remote_file(agent, user_facts_path, ext_user_fact('USER_PRECEDENCE_FACTER'))
    create_remote_file(agent, user_puppetlabs_facts_path, ext_user_fact('USER_PRECEDENCE_PUPPETLABS'))

    step "Agent #{agent}: chown and chmod the facts to the user #{non_root_user}"
    on(agent, "chown -R #{non_root_user} #{user_base_facts_dir} #{user_base_puppetlabs_dir}")
    on(agent, "chmod -R a+rx #{user_base_facts_dir} #{user_base_puppetlabs_dir}")

    step "Agent #{agent}: run facter as #{non_root_user} and .facter will take precedence over .puppetlabs"
    on(agent, %Q[su #{non_root_user} -c "#{facter_path} test"]) do
      assert_match(/USER_PRECEDENCE_FACTER/, stdout, "Fact from #{user_puppetlabs_facts_dir} did not resolve correctly")
    end
  end
end
