# This test is intended to demonstrate that setting a ttl on a resolver set
# caches the fact information for later facter invocations.  This test also
# covers various failures in the caching mechanism
test_name "ttls config field stores and retreives cached facts" do
  require 'facter/acceptance/user_fact_utils'
  extend ::Facter::Acceptance::UserFactUtils

  config = <<EOM
facts : {
    ttls : [
        { "uptime" : 30 days }
    ]
}
EOM

  config_no_cache = <<EOM
facts : {
  ttls : [ ]
}
EOM

  # This fact must be resolvable on ALL platforms
  # Do NOT use the 'kernel' fact as it is used to configure the tests
  cached_factname = 'uptime'
  cached_fact_content = <<EOM
{
  "uptime": "cachedfact"
}
EOM
  empty_cached_fact_content = <<EOM
{ }
EOM

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      config_file = File.join(config_dir, "facter.conf")
      cached_facts_dir = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

      cached_fact_file = File.join(cached_facts_dir, cached_factname)

      # Setup facter conf
      on(agent, "mkdir -p '#{config_dir}'")
      create_remote_file(agent, config_file, config)

      teardown do
        on(agent, "rm -rf '#{config_dir}'", :acceptable_exit_codes => [0,1])
        on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0,1])
      end

      step "should create a JSON file for a fact that is to be cached" do
        on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0,1])
        on(agent, facter("--debug")) do
          assert_match(/caching values for .+ facts/, stderr, "Expected debug message to state that values will be cached")

          on(agent,"cat #{cached_fact_file}", :acceptable_exit_codes => [0]) do
            assert_match(/#{cached_factname}/, stdout, "Expected cached fact file to contain fact information")
          end
        end
      end

      step "should read from a cached JSON file for a fact that has been cached" do
        # Setup a known cached fact
        on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0,1])
        on(agent, facter(""))
        create_remote_file(agent, cached_fact_file, cached_fact_content)

        on(agent, facter("#{cached_factname} --debug")) do
          assert_match(/loading cached values for .+ facts/, stderr, "Expected debug message to state that values are read from cache")
          assert_match(/cachedfact/, stdout, "Expected fact to match the cached fact file")
        end
      end

      step "should return an empty string for an empty JSON document" do
        # Setup a known cached fact
        on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0,1])
        on(agent, facter(""))
        create_remote_file(agent, cached_fact_file, empty_cached_fact_content)

        on(agent, facter("#{cached_factname}")) do
          assert(stdout.chomp == '', "Expected fact to be empty")
        end
      end

      step "should not read from a cached JSON file for a fact that has been cached but TTL expired" do
        # Setup a known cached fact
        on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0,1])
        on(agent, facter(""))
        create_remote_file(agent, cached_fact_file, cached_fact_content)
        # Change the modified date to sometime in the far distant past
        on(agent, "touch -mt 198001010000 '#{cached_fact_file}'")

        on(agent, facter("#{cached_factname}")) do
          assert_not_match(/cachedfact/, stdout, "Expected fact to not match the cached fact file")
        end
      end

      step "should refresh an expired cached fact" do
        # Setup a known cached fact
        on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0,1])
        on(agent, facter(""))
        create_remote_file(agent, cached_fact_file, cached_fact_content)
        # Change the modified date to sometime in the far distant past
        on(agent, "touch -mt 198001010000 '#{cached_fact_file}'")
        # Force facter to recache
        on(agent, facter("#{cached_factname}"))

        # Read cached fact file content
        on(agent,"cat #{cached_fact_file}", :acceptable_exit_codes => [0]) do
          assert(cached_fact_content != stdout, "Expected cached fact file to be refreshed")
        end
      end

      step "should refresh a cached fact if cache file is corrupt" do
        # Setup a known cached fact
        on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0,1])
        on(agent, facter(""))
        # Corrupt the cached fact file
        create_remote_file(agent, cached_fact_file, 'ThisIsNotvalidJSON')

        on(agent, facter("#{cached_factname}")) do
          assert_match(/.+/, stdout, "Expected fact to be resolved")
        end

        # Expect the fact file to exist
        assert(agent.file_exist?("#{cached_fact_file}"), "Expected cache file to exist")
      end

      # When calling Facter from Puppet
      step "when Facter is called from Puppet" do
        facter_conf_default_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
        facter_conf_default_path = File.join(facter_conf_default_dir, "facter.conf")

        teardown do
          on(agent, "rm -rf '#{facter_conf_default_dir}'", :acceptable_exit_codes => [0,1])
        end

        step "Create default facter.conf file" do
          # create the directories
          on(agent, "mkdir -p '#{facter_conf_default_dir}'")
          create_remote_file(agent, facter_conf_default_path, config)
        end

        step "should create a JSON file for a fact that is to be cached" do
          on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0,1])
          on(agent, puppet("facts --debug")) do
            assert_match(/caching values for .+ facts/, stdout, "Expected debug message to state that values will be cached")

            on(agent,"cat #{cached_fact_file}", :acceptable_exit_codes => [0]) do
              assert_match(/#{cached_factname}/, stdout, "Expected cached fact file to contain fact information")
            end
          end
        end

        step "should read from a cached JSON file for a fact that has been cached" do
          # Setup a known cached fact
          on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0,1])
          on(agent, puppet("facts"))
          create_remote_file(agent, cached_fact_file, cached_fact_content)

          on(agent, puppet("facts --debug")) do
            assert_match(/loading cached values for .+ facts/, stdout, "Expected debug message to state that values are read from cache")
            assert_match(/cachedfact/, stdout, "Expected fact to match the cached fact file")
          end
        end
      end

      step "should clean out unused cache files on each facter run" do
        step "Agent #{agent}: create config file with no cached facts" do
          # Set up a known cached fact
          on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0, 1])
          on(agent, facter(""))
          create_remote_file(agent, cached_fact_file, cached_fact_content)

          # Create config file with no caching
          no_cache_config_file = File.join(config_dir, "no-cache.conf")
          create_remote_file(agent, no_cache_config_file, config_no_cache)

          on(agent, facter("--config '#{no_cache_config_file}'"))
          # Expect cache file to not exist
          refute(agent.file_exist?("#{cached_fact_file}"), "Expected cache file to be absent")
        end
      end

    end
  end
end
