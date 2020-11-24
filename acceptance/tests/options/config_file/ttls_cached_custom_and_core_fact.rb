test_name 'missing facts should not invalidate cache' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  custom_fact_file = 'custom_fact.rb'
  custom_fact_name = 'my_custom_fact'
  custom_cache_group = 'my_custom_group'
  custom_fact_value = 'banana'
  core_fact_name = 'system_uptime.seconds'

  fact_content = <<-CUSTOM_FACT
    Facter.add('#{custom_fact_name}') do
      setcode do
        "#{custom_fact_value}"
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
          { "#{custom_cache_group}" : 3 days }
        ]
      }

      fact-groups : {
        "#{custom_cache_group}" : ["#{custom_fact_name}", "#{core_fact_name}"],
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

    step 'request the core fact' do
      @core_value = on(agent, facter(core_fact_name, environment: env)).stdout.strip.to_i

      cat_output = agent.cat("#{cache_folder}/#{custom_cache_group}")
      cache = JSON.parse(cat_output)

      step 'check if it is the only fact on cache' do
        cached = { core_fact_name => @core_value, 'cache_format_version' => 1 }
        assert_equal(cached, cache)
      end

      step 'check that it cached the value it printed' do
        assert_equal(@core_value, cache[core_fact_name])
      end
    end

    step 'request the core fact again' do
      core_value = on(agent, facter(core_fact_name, environment: env)).stdout.strip.to_i

      cat_output = agent.cat("#{cache_folder}/#{custom_cache_group}")
      cache = JSON.parse(cat_output)

      step 'check that it cached the value it printed' do
        assert_equal(core_value, cache[core_fact_name])
      end

      step 'check that core value did not change' do
        assert_equal(@core_value, core_value)
      end
    end

    step 'request the custom fact' do
      @custom_fact_value = on(agent, facter(custom_fact_name, environment: env)).stdout.strip

      cat_output = agent.cat("#{cache_folder}/#{custom_cache_group}")
      cache = JSON.parse(cat_output)

      step 'check if it is the only fact on cache' do
        cached = { custom_fact_name => @custom_fact_value, 'cache_format_version' => 1 }
        assert_equal(cached, cache)
      end

      step 'check that it cached the value it printed' do
        assert_equal(@custom_fact_value, cache[custom_fact_name].to_s)
      end
    end

    step 'request the custom fact again' do
      custom_fact_value = on(agent, facter(custom_fact_name, environment: env)).stdout.strip

      cat_output = agent.cat("#{cache_folder}/#{custom_cache_group}")
      cache = JSON.parse(cat_output)

      step 'check that it cached the value it printed' do
        assert_equal(custom_fact_value, cache[custom_fact_name].to_s)
      end

      step 'check that the value did not change' do
        assert_equal(@custom_fact_value, custom_fact_value)
      end
    end

    step "updates cache file with full group contents" do
      on(agent, facter('', environment: env))
      cat_output = agent.cat("#{cache_folder}/#{custom_cache_group}")
      cache = JSON.parse(cat_output)

      step 'cache contains core and custom fact' do
        cache_keys = cache.keys - ['cache_format_version']
        assert_equal([custom_fact_name, core_fact_name].sort, cache_keys.sort)
      end

      step 'reads the cache file' do
        cache_hash = {
          custom_fact_name => "pine apple",
          "system_uptime.seconds" => 2,
          "cache_format_version" => 1
        }

        create_remote_file(agent, "#{cache_folder}/#{custom_cache_group}", cache_hash.to_json)

        step 'custom fact is read correctly' do
          output = on(agent, facter(custom_fact_name, environment: env))
          assert_equal(cache_hash[custom_fact_name], output.stdout.strip )
        end

        step 'core fact is read correctly' do
          output = on(agent, facter(core_fact_name, environment: env))
          assert_equal(cache_hash[core_fact_name].to_s, output.stdout.strip )
        end
      end
    end
  end
end
