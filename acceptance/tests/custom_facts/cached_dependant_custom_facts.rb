test_name 'dependant custom facts are cached correctly' do
  tag 'risk:high'
      
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils
      
  custom_fact_file = 'dependant_custom_facts.rb'
  depending_fact_name  = 'depending_fact_name'

  simple_fact_name  = 'simple_fact_name'
  simple_fact_value = '["a","b","c","d"]'

  fact_content = <<-CUSTOM_FACT
  Facter.add(:#{simple_fact_name}) do
    confine osfamily: Facter.value('osfamily').downcase
    setcode do
      array_value = #{simple_fact_value}
      array_value
    end
  end
  
  Facter.add(:#{depending_fact_name}) do
    confine osfamily: Facter.value('osfamily').downcase
    setcode do
      Facter.value(:#{simple_fact_name}).length
    end
  end
  CUSTOM_FACT
       
  cached_file_content = <<~CACHED_FILE
    {
      "#{depending_fact_name}": 4,
      "cache_format_version": 1
    }
  CACHED_FILE
       
  config_data = <<~FACTER_CONF
    facts : {
      ttls : [
  	{ "cached-dependant-custom-facts" : 3 days }
      ]
    }
    fact-groups : {
      cached-dependant-custom-facts : ["#{depending_fact_name}","#{simple_fact_name}"],
    }
  FACTER_CONF
       
  agents.each do |agent|
    facter_version = fact_on(agent, 'facterversion')

    if facter_version.start_with?("3")
      skip_test 'Test only viable on Facter 4'
    end

    cache_folder = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    fact_dir = agent.tmpdir('facter')
    env = { 'FACTERLIB' => fact_dir }
       
    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, 'facter.conf')
       
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

    step "should log that it creates cache file and it caches custom facts found in facter.conf" do
      on(agent, facter("#{depending_fact_name} --debug", environment: env)) do |facter_result|
        assert_equal("4", facter_result.stdout.chomp, "#{depending_fact_name} value changed")
        assert_match(/facts cache file expired, missing or is corrupt/, facter_result.stderr,
  	   'Expected debug message to state that depending custom facts cache file is missing or expired')
        assert_match(/caching values for cached-dependant-custom-facts facts/, facter_result.stderr,
  	   'Expected debug message to state that depending custom facts will be cached')
      end
    end
       
    step "should create a cached-dependant-custom-facts cache file that containt fact information" do
      result = agent.file_exist?("#{cache_folder}/cached-dependant-custom-facts")
      assert_equal(true, result)
      cat_output = agent.cat("#{cache_folder}/cached-dependant-custom-facts")
      assert_match(cached_file_content.chomp, cat_output.strip, 'Expected cached dependant custom fact file to contain fact information')
    end
       
    step 'should read from the cached file for a custom fact that has been cached' do
      on(agent, facter("#{depending_fact_name} --debug", environment: env)) do |facter_result|
        assert_match(/loading cached values for #{depending_fact_name} facts/, facter_result.stderr,
  	   'Expected debug message to state that cached custom facts are read from file')
      end
    end
  end
end
