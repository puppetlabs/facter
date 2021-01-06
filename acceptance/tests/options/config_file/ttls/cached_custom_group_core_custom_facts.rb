test_name 'ttls configured with custom group containing core and custom facts' do
  tag 'risk:high'

  skip_test "Known issue. Scenario does not work."

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  custom_fact_file = 'custom_facts.rb'
  custom_fact_name  = 'random_custom_fact'
  uptime_seconds_value = ''

  custom_fact_content = <<-CUSTOM_FACT
  Facter.add(:#{custom_fact_name}) do
    setcode do
      Facter.value('system_uptime.seconds')
    end
  end
  CUSTOM_FACT

  config_data = <<~FACTER_CONF
    facts : {
      ttls : [
          { "cached-custom-facts" : 3 days },
      ]
    }
    fact-groups : {
      cached-custom-facts : ["#{custom_fact_name}", "system_uptime"],
    }
  FACTER_CONF

  agents.each do |agent|
    cache_folder = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    fact_dir = agent.tmpdir('facter')
    env = { 'FACTERLIB' => fact_dir }

    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, 'facter.conf')

    step "Agent #{agent}: create config file" do
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config_data)
      
      fact_file = File.join(fact_dir, custom_fact_file)
      create_remote_file(agent, fact_file, custom_fact_content)
    
      teardown do
        agent.rm_rf(fact_dir)
        agent.rm_rf("#{cache_folder}/*")
        agent.rm_rf(config_file)
      end

      step "should log that it creates cache file and it caches custom facts found in facter.conf" do
        on(agent, facter("--debug --json", environment: env)) do |facter_result|
          output_json = JSON.parse(facter_result.stdout.chomp)
          uptime_seconds_value = output_json['system_uptime']['seconds']
          assert_match(/caching values for cached-custom-facts facts/, facter_result.stderr,
                      'Expected debug message to state that custom facts will be cached')
        end
      end

      step "should create a cached-custom-facts cache file that contains fact information" do
        result = agent.file_exist?("#{cache_folder}/cached-custom-facts")
        assert_equal(true, result)
        cat_output = agent.cat("#{cache_folder}/cached-custom-facts")
        output_json = JSON.parse(cat_output.chomp)
        assert_match(output_json[custom_fact_name], uptime_seconds_value, 'Expected cached custom fact file to contain fact information')
        assert_match(output_json['system_uptime.seconds'], uptime_seconds_value, 'Expected cached file to contain system_uptime information')
      end

      step 'should read from the cached file for a custom fact that has been cached' do
        on(agent, facter("--debug", environment: env)) do |facter_result|
          output_json = JSON.parse(facter_result.stdout.chomp)
          
          assert_match(output_json[custom_fact_name], uptime_seconds_value, 'Expected cached custom fact file to contain fact information')
          assert_match(output_json['system_uptime.seconds'], uptime_seconds_value, 'Expected cached file to contain system_uptime information')

          assert_match(/caching values for cached-custom-facts facts/, facter_result.stderr,
                      'Expected debug message to state that custom facts will be cached')
          assert_match(/loading cached values for #{custom_fact_name} facts/, facter_result.stderr,
                      'Expected debug message to state that cached custom facts are read from file')
          assert_match(/loading cached values for system_uptime.seconds facts/, facter_result.stderr,
                      'Expected debug message to state that system_uptime facts are read from file')
        end
      end
    end
  end
end