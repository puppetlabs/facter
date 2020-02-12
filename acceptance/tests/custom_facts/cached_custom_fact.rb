test_name 'ttls configured custom facts files creates cache file and reads cache file' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  custom_fact_file = 'custom_facts.rb'
  custom_fact_name  = 'random_custom_fact'
  custom_fact_value = 'custom fact value'

  fact_content = <<-CUSTOM_FACT
  Facter.add(:#{custom_fact_name}) do
    setcode do
      "#{custom_fact_value}"
    end
  end
  CUSTOM_FACT

  cached_file_content = <<~CACHED_FILE
    {
      "#{custom_fact_name}": "#{custom_fact_value}"
    }
  CACHED_FILE

  config_data = <<~FACTER_CONF
    facts : {
      ttls : [
          { "cached-custom-facts" : 3 days }
      ]
      cached-custom-facts : [ "#{custom_fact_name}" ]
    }
  FACTER_CONF

  agents.each do |agent|
    cache_folder = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    fact_dir = agent.tmpdir('facter')
    env = { 'FACTERLIB' => fact_dir }

    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, 'facter.conf')

    step "Agent #{agent}: create config file" do
      on(agent, "mkdir -p '#{config_dir}'")
      create_remote_file(agent, config_file, config_data)
      fact_file = File.join(fact_dir, custom_fact_file)
      create_remote_file(agent, fact_file, fact_content)
    end

    teardown do
      on(agent, "rm -rf '#{fact_dir}'")
      on(agent, "rm -rf #{cache_folder}/*")
      on(agent, "rm -rf '#{config_file}'")
    end

    step "should log that it creates cache file and it caches custom facts found in facter.conf" do
      on(agent, facter("#{custom_fact_name} --debug", environment: env)) do |facter_result|
        assert_equal(custom_fact_value, facter_result.stdout.chomp, "#{custom_fact_name} value changed")
        assert_match(/Custom facts cache file expired\/missing. Refreshing/, facter_result.stderr,
                     'Expected debug message to state that custom facts cache file is missing or expired')
        assert_match(/Saving cached custom facts to ".+"/, facter_result.stderr,
                     'Expected debug message to state that custom facts will be cached')
      end
    end

    step "should create a cached-custom-facts cache file that containt fact information" do
      on(agent, "test -f #{cache_folder}/cached-custom-facts && echo \"Cache file exists\"") do |file_check_output|
        assert_equal('Cache file exists', file_check_output.stdout.chomp, "Cache file does not exists in #{cache_folder}")
      end
      on(agent, "cat #{cache_folder}/cached-custom-facts", acceptable_exit_codes: [0]) do |cat_output|
        assert_match(cached_file_content.chomp, cat_output.stdout, 'Expected cached custom fact file to contain fact information')
      end
    end

    step 'should read from the cached file for a custom fact that has been cached' do
      on(agent, facter("#{custom_fact_name} --debug", environment: env)) do |facter_result|
        assert_match(/Loading cached custom facts from file ".+"/, facter_result.stderr,
                     'Expected debug message to state that cached custom facts are read from file')
      end
    end
  end
end
