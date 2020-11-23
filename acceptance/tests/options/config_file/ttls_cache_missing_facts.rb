test_name 'missing facts should not invalidate cache' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  custom_fact_file = 'custom_facts.rb'

  fact_content = <<-CUSTOM_FACT
    Facter.add("networking.custom_fact") do
      setcode do
        ''
      end
    end
  CUSTOM_FACT


  agents.each do |agent|
    cache_folder = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    fact_dir = agent.tmpdir('facter')
    env = { 'FACTERLIB' => fact_dir }

    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, 'facter.conf')

    config_data = <<~FACTER_CONF
      facts : {
        ttls : [
          { "networking" : 3 days }
        ]
      }
    FACTER_CONF

    step "Agent #{agent}: create config file" do
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config_data)

      fact_file = File.join(fact_dir, custom_fact_file)
      create_remote_file(agent, fact_file, fact_content)
    end

    teardown do
      agent.rm_rf(fact_dir)
      agent.rm_rf("#{cache_folder}/*")
      agent.rm_rf(config_file)
    end

    step "should create cache file once" do
      on(agent, facter('', environment: env))
      ls1 = agent.ls_ld("#{cache_folder}/networking")
      sleep 1
      on(agent, facter('', environment: env))
      ls2 = agent.ls_ld("#{cache_folder}/networking")

      assert_equal(ls1, ls2)
    end
  end
end
