# Verify that facter uses the new AIO default paths for external facts
#
# On Unix/Linux/OS X, there are three directories:
#     /opt/puppetlabs/facter/facts.d/
#     /etc/puppetlabs/facter/facts.d/
#     /etc/facter/facts.d/
test_name "C59201: Fact directory precedence and resolution order for facts" do
  tag 'risk:high'

  confine :except, :platform => 'windows' # windows only supports 1 directory instead of 3 on unix

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

# Generate an external fact dynamically
  def ext_fact(value='BASIC')
    "test: '#{value}'"
  end

  agents.each do |agent|
    # The directories that facter processes facts
    os_version = on(agent, facter("kernelmajversion #{@options[:trace]}")).stdout.chomp.to_f
    factsd_dir = get_factsd_dir(agent['platform'], os_version)
    etc_factsd_dir = get_etc_factsd_dir(agent['platform'])
    etc_puppetlabs_factsd_dir = get_etc_puppetlabs_factsd_dir(agent['platform'])
    factsd_path = "#{factsd_dir}/test.yaml"
    etc_factsd_path = "#{etc_factsd_dir}/test.yaml"
    etc_puppetlabs_factsd_path = "#{etc_puppetlabs_factsd_dir}/test.yaml"

    teardown do
      agent.rm_rf(factsd_dir)
      agent.rm_rf(etc_factsd_dir)
      agent.rm_rf(etc_puppetlabs_factsd_dir)
    end

    # ensure the fact directory we want to use exists
    step "Agent #{agent}: create facts directory (#{etc_puppetlabs_factsd_dir})" do
      agent.rm_rf(etc_puppetlabs_factsd_dir)
      agent.mkdir_p(etc_puppetlabs_factsd_dir)
    end

    # A fact in the etc_puppetlabs_factsd_dir directory should resolve to the fact
    step "Agent #{agent}: create and resolve a custom fact in #{etc_puppetlabs_factsd_dir}" do
      create_remote_file(agent, etc_puppetlabs_factsd_path, ext_fact('etc_puppetlabs_path'))
      on(agent, facter("test #{@options[:trace]}")) do |facter_output|
        assert_match(/etc_puppetlabs_path/, facter_output.stdout, "Fact from #{etc_puppetlabs_factsd_dir} did not resolve correctly")
      end
    end

    # remove the fact
    step "Agent #{agent}: remove the fact in #{etc_puppetlabs_factsd_dir}" do
      agent.rm_rf(etc_puppetlabs_factsd_path)
    end

    # ensure the fact directory we want to use exists
    step "Agent #{agent}: create facts directory (#{etc_factsd_dir})" do
      agent.rm_rf(etc_factsd_dir)
      agent.mkdir_p(etc_factsd_dir)
    end

    # A fact in the etc_factsd_dir directory should resolve to the fact
    step "Agent #{agent}: create and resolve a custom fact in #{etc_factsd_dir}" do
      create_remote_file(agent, etc_factsd_path, ext_fact('etc_path'))
      on(agent, facter("test #{@options[:trace]}")) do |facter_output|
        assert_match(/etc_path/, facter_output.stdout, "Fact from #{etc_factsd_dir} did not resolve correctly")
      end
    end

    # remove the fact
    step "Agent #{agent}: remove the fact in #{etc_factsd_dir}" do
      agent.rm_rf(etc_factsd_path)
    end

    # ensure the fact directory we want to use exists
    step "Agent #{agent}: create facts directory (#{factsd_dir})" do
      agent.rm_rf(factsd_dir)
      agent.mkdir_p(factsd_dir)
    end

    # A fact in the factsd_dir directory should resolve to the fact
    step "Agent #{agent}: create and resolve a custom fact in #{factsd_dir}" do
      create_remote_file(agent, factsd_path, ext_fact('default_factsd'))
      on(agent, facter("test #{@options[:trace]}")) do |facter_output|
        assert_match(/default_factsd/, facter_output.stdout, "Fact from #{factsd_dir} did not resolve correctly")
      end
    end

    # remove the fact
    step "Agent #{agent}: remove the fact in #{factsd_dir}" do
      agent.rm_rf(factsd_path)
    end

    # A fact in the etc_factsd_dir directory should take precedence over the same fact in factsd_dir
    step "Agent #{agent}: create and resolve 2 facts of the same name between #{factsd_dir} and #{etc_factsd_dir}" do
      create_remote_file(agent, factsd_path, ext_fact('BASE'))
      create_remote_file(agent, etc_factsd_path, ext_fact('ETC_FACTS'))
      on(agent, facter("test #{@options[:trace]}")) do |facter_output|
        assert_match(/ETC_FACTS/, facter_output.stdout, "Fact from #{etc_factsd_dir} should take precedence over #{factsd_dir}")
      end
    end

    # A fact in the etc_puppetlabs_factsd_dir should take precedence over the same fact in etc_factsd_dir
    step "Agent #{agent}: create and resolve 2 facts of the same name between #{etc_factsd_dir} and #{etc_puppetlabs_factsd_dir}" do
      create_remote_file(agent, etc_factsd_path, ext_fact('ETC_FACTS'))
      create_remote_file(agent, etc_puppetlabs_factsd_path, ext_fact('ETC_PUPPETLABS_FACTS'))
      on(agent, facter("test #{@options[:trace]}")) do |facter_output|
        assert_match(/ETC_PUPPETLABS_FACTS/, facter_output.stdout, "Fact from #{etc_puppetlabs_factsd_dir} should take precedence over #{etc_factsd_dir}")
      end
    end
  end
end
