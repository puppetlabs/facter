test_name 'ttls configured with all types of facts' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  custom_fact_file = 'custom_facts.rb'
  custom_fact_name  = 'random_custom_fact'
  custom_fact_value = 'custom fact value'

  custom_fact_content = <<-CUSTOM_FACT
  Facter.add(:#{custom_fact_name}) do
    setcode do
      "#{custom_fact_value}"
    end
  end
  CUSTOM_FACT

  external_fact_name = 'external_fact'
  external_fact_value = 'external_value'
  external_fact_content = <<-EXTERNAL_FACT
    #{external_fact_name}=#{external_fact_value}
    EXTERNAL_FACT

  cached_file_content = <<~CACHED_FILE
    {
      "#{custom_fact_name}": "#{custom_fact_value}",
      "#{external_fact_name}": "#{external_fact_name}",
      "cache_format_version": 1
    }
  CACHED_FILE

  config_data = <<~FACTER_CONF
    facts : {
      ttls : [
          { "cached-custom-facts" : 3 days },
          { "#{external_fact_name}.txt": 3 days}
      ]
    }
    fact-groups : {
      cached-custom-facts : ["#{custom_fact_name}", "uptime"],
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

      external_dir = agent.tmpdir('external_dir')
      external_fact = File.join(external_dir, "#{external_fact_name}.txt")
      create_remote_file(agent, external_fact, external_fact_content)
    
      teardown do
        agent.rm_rf(fact_dir)
        agent.rm_rf("#{cache_folder}/*")
        agent.rm_rf(config_file)
        agent.rm_rf(external_dir)
      end

      step "should log that it creates cache file and it caches custom facts found in facter.conf" do
        on(agent, facter("--external-dir \"#{external_dir}\" --debug", environment: env)) do |facter_result|
          assert_match(/#{custom_fact_value}/, facter_result.stdout.chomp, "#{custom_fact_name} value changed")
          assert_match(/#{external_fact_value}/, facter_result.stdout.chomp, "#{external_fact_name} value changed")
          assert_match(/caching values for cached-custom-facts facts/, facter_result.stderr,
                      'Expected debug message to state that custom facts will be cached')
          assert_match(/caching values for #{external_fact_name}.txt facts/, facter_result.stderr,
                      'Expected debug message to state that custom facts will be cached')
        end
      end

      step "should create a cached-custom-facts cache file that containt fact information" do
        result = agent.file_exist?("#{cache_folder}/cached-custom-facts")
        assert_equal(true, result)
        cat_output = agent.cat("#{cache_folder}/cached-custom-facts")
        cat_external = agent.cat("#{cache_folder}/#{external_fact_name}.txt")
        assert_match(/#{custom_fact_value}/, cat_output.strip, 'Expected cached custom fact file to contain fact information')
        assert_match(/uptime/, cat_output.strip, 'Expected cached custom fact file to contain fact information')
        assert_match(/#{external_fact_value}/, cat_external.strip, 'Expected cached custom fact file to contain fact information')
      end

      step 'should read from the cached file for a custom fact that has been cached' do
        on(agent, facter("--external-dir \"#{external_dir}\" --debug", environment: env)) do |facter_result|
          assert_match(/loading cached values for #{custom_fact_name} facts/, facter_result.stderr,
                      'Expected debug message to state that cached custom facts are read from file')
          assert_match(/loading cached values for #{external_fact_name}.txt facts/, facter_result.stderr,
                      'Expected debug message to state that cached custom facts are read from file')
          assert_match(/loading cached values for uptime facts/, facter_result.stderr,
                      'Expected debug message to state that cached custom facts are read from file')
        end
      end
    end
  end
end