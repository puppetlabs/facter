# This test is intended to verify that when the ttls list in the config file is empty
# that the existing cached facts are removed
test_name "C100125: ttls config that is empty causes facter to remove existing cached facts" do
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

  config = <<EOM
facts : {
  ttls : [
      { "#{cached_fact_name}" : 30 days }
  ]
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

      # Setup facter conf
      on(agent, "mkdir -p '#{config_dir}'")
      create_remote_file(agent, config_file, config)

      teardown do
        on(agent, "rm -rf '#{config_dir}'", :acceptable_exit_codes => [0, 1])
        on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0, 1])
      end

      step "Agent #{agent}: create config file with no cached facts" do
        # Set up a known cached fact
        on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0, 1])
        on(agent, facter(""))
        create_remote_file(agent, cached_fact_file, cached_fact_content)
      end

      step "Agent #{agent}: clean out unused cache files on each facter run" do
        # Create config file with no caching
        no_cache_config_file = File.join(config_dir, "no-cache.conf")
        create_remote_file(agent, no_cache_config_file, config_no_cache)

        on(agent, facter("--config '#{no_cache_config_file}'")) do |facter_output|
          assert_no_match(/#{cached_fact_value}/, facter_output.stdout, "Expected to not see the cached fact value")
        end

        # Expect cache file to not exist
        refute(agent.file_exist?("#{cached_fact_file}"), "Expected cache file to be absent")
      end
    end
  end
end
