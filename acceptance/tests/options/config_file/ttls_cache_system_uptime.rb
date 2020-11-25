test_name 'ttls configured custom facts files creates cache file and reads cache file' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  config_data = <<~FACTER_CONF
    facts : {
      ttls : [
          { "uptime" : 3 days }

      ]
    }
  FACTER_CONF

  agents.each do |agent|
    cache_folder = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, 'facter.conf')

    step "Agent #{agent}: create config file" do
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config_data)
    end

    teardown do
      agent.rm_rf("#{cache_folder}/*")
      agent.rm_rf(config_file)
    end

    step "calling one fact from the cached group will cache only that fact" do
      output = on(agent, facter('system_uptime.seconds'))

      seconds = output.stdout.strip.to_i
      expected = { "system_uptime.seconds" => seconds, "cache_format_version" => 1 }

      stdout = agent.cat("#{cache_folder}/uptime")
      cache_content = JSON.parse(stdout)

      assert_equal(expected, cache_content)
    end

    # TODO: This is a knoew issue and needs to be fixed
    # Added this step just to have quick validation
    #
    # step "calling a fact with the same name as the group should work" do
    #   output = on(agent, "facter uptime")
    #   uptime = output.stdout.strip

    #   stdout = agent.cat("#{cache_folder}/uptime")
    #   cache_content = JSON.parse(stdout)

    #   expected = { "uptime" => uptime, "cache_format_version" => 1 }

    #   assert_equal(expected, cache_content)
    # end

    step "calling facter without a query will cache the entire group" do
      _output = on(agent, facter)

      stdout = agent.cat("#{cache_folder}/uptime")
      cache_content = JSON.parse(stdout)
      ["system_uptime.days",
        "uptime_days",
        "system_uptime.hours",
        "uptime_hours",
        "system_uptime.seconds",
        "uptime_seconds",
        "system_uptime.uptime",
        "uptime",
        "cache_format_version"].each do |key|

          assert_equal(true, cache_content.has_key?(key))
        end
    end

    step "calling a single fact fron the cached group will not overwrite the file" do
      _output = on(agent, facter('system_uptime.seconds'))

      stdout = agent.cat("#{cache_folder}/uptime")
      cache_content = JSON.parse(stdout)
      ["system_uptime.days",
        "uptime_days",
        "system_uptime.hours",
        "uptime_hours",
        "system_uptime.seconds",
        "uptime_seconds",
        "system_uptime.uptime",
        "uptime",
        "cache_format_version"].each do |key|

          assert_equal(true, cache_content.has_key?(key))
        end
    end
  end
end
