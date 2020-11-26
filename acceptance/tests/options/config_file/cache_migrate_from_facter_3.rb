test_name 'migrating from facter 3 to facter 4 having cache enabled' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  fact_group_name = 'uptime'
  config_data = <<~FACTER_CONF
    facts : {
      ttls : [
          { "#{fact_group_name}" : 3 days }

      ]
    }
  FACTER_CONF

  f3_cache =
    "{
      \"system_uptime\": {
        \"days\": 1,
        \"hours\": 1,
        \"seconds\": 1,
        \"uptime\": \"1 day\"
      },
      \"uptime\": \"1 days\",
      \"uptime_days\": 1,
      \"uptime_hours\": 1,
      \"uptime_seconds\": 1
    }"

  agents.each do |agent|
    cache_dir = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    f3_cache_file = File.join(cache_dir, fact_group_name)

    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, 'facter.conf')

    step 'create cache file' do
      agent.mkdir_p(cache_dir)
      create_remote_file(agent, f3_cache_file, f3_cache)
    end

    teardown do
      agent.rm_rf("#{cache_dir}/*")
      agent.rm_rf(config_file)
    end

    step 'calling facter 4 without config won\'t modify the cache file' do
      _output = on(agent, facter)
      stdout = agent.cat("#{cache_dir}/#{fact_group_name}")

      assert_equal(stdout.strip, f3_cache.strip)
    end

    step "Agent #{agent}: create config file" do
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config_data)
    end

    step 'calling facter will invalidate old f3 cache and will overwrite' do
      output = on(agent, facter('--json'))

      step 'output should be different from f3 cache' do
        parsed_output = JSON.parse(output.stdout)

        cache_value_changed = f3_cache['system_uptime']['seconds'] != parsed_output['system_uptime']['seconds']
        assert_equal(true, cache_value_changed, 'Cache value did not change')
      end

      step 'cache file should contain cache_format_version' do
        stdout = agent.cat("#{cache_dir}/#{fact_group_name}")
        cache_content = JSON.parse(stdout)

        assert_equal(cache_content['cache_format_version'], 1)

        step 'values should be read from cache' do
          cached_value = cache_content['system_uptime.seconds']
          sleep 1
          output = on(agent, facter('system_uptime.seconds'))

          assert_equal(cached_value.to_s, output.stdout.strip)
        end
      end
    end
  end
end
