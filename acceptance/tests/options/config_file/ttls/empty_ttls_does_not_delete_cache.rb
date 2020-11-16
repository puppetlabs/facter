test_name "clearing ttls does not delete cache" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  # This fact must be resolvable on ALL platforms
  # Do NOT use the 'kernel' fact as it is used to configure the tests
  cached_fact_name = 'uptime'
  cached_fact_value = "CACHED_FACT_VALUE"
  cached_fact_content = <<EOM
{
 "#{cached_fact_name}": "#{cached_fact_value}"
}
EOM

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

  config = <<EOM
  facts : {
    ttls : [
        { "#{cached_fact_name}" : 3 days },
        { "#{external_fact_name}.txt": 3 days}
        { "cached-custom-facts": 3 days}
    ]
  }
  fact-groups : {
    cached-custom-facts : ["#{custom_fact_name}"],
  }
EOM

  config_no_cache = <<EOM
facts : {
   ttls : [ ]
}
EOM

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      config_file = File.join(config_dir, "facter.conf")
      cached_facts_dir = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

      cached_fact_file = File.join(cached_facts_dir, cached_fact_name)

      fact_dir = agent.tmpdir('facter')
      env = { 'FACTERLIB' => fact_dir }

      # Setup facter conf
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config)

      fact_file = File.join(fact_dir, custom_fact_file)
      create_remote_file(agent, fact_file, custom_fact_content)

      external_dir = agent.tmpdir('external_dir')
      external_fact = File.join(external_dir, "#{external_fact_name}.txt")
      create_remote_file(agent, external_fact, external_fact_content)

      teardown do
        agent.rm_rf(fact_dir)
        agent.rm_rf("#{cached_facts_dir}/*")
        agent.rm_rf(config_file)
        agent.rm_rf(external_dir)
      end

      step "Agent #{agent}: run facter with cached facts" do
        # Set up a known cached fact  
        agent.rm_rf(cached_facts_dir)
        on(agent, facter("--external-dir \"#{external_dir}\"", environment: env))
        assert_equal(true, agent.file_exist?("#{cached_facts_dir}/cached-custom-facts"))
        assert_equal(true, agent.file_exist?("#{cached_facts_dir}/#{cached_fact_name}"))
        assert_equal(true, agent.file_exist?("#{cached_facts_dir}/#{external_fact_name}.txt"))
        create_remote_file(agent, cached_fact_file, cached_fact_content)
      end

      step "Agent #{agent}: resolves fact after ttls was removed" do
        # Create config file with no caching
        no_cache_config_file = File.join(config_dir, "no-cache.conf")
        create_remote_file(agent, no_cache_config_file, config_no_cache)

        on(agent, facter("--config \"#{no_cache_config_file}\" --external-dir \"#{external_dir}\"", environment: env)) do |facter_output|
          assert_match(/#{cached_fact_name}/, facter_output.stdout, "Expected to see the fact in output")
          assert_no_match(/#{cached_fact_value}/, facter_output.stdout, "Expected to not see the cached fact value")
        end

        assert_equal(true, agent.file_exist?("#{cached_facts_dir}/cached-custom-facts"))
        assert_equal(true, agent.file_exist?("#{cached_facts_dir}/#{cached_fact_name}"))
        assert_equal(true, agent.file_exist?("#{cached_facts_dir}/#{external_fact_name}.txt"))

      end
    end
  end
end
