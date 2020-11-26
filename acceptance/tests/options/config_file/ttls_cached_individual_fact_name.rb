# This test verifies that individual facts can be cached
test_name "ttls config that contains fact name caches individual facts" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  # This fact must be resolvable on ALL platforms
  # Do NOT use the 'kernel' fact as it is used to configure the tests
  cached_fact_name = 'system_uptime.days'
  cached_fact_value = "CACHED_FACT_VALUE"
  cached_fact_content = <<EOM
{
 "#{cached_fact_name}": "#{cached_fact_value}",
 "cache_format_version": 1
}
EOM

  config = <<EOM
facts : {
  ttls : [
      { "#{cached_fact_name}" : 30 days }
  ]
}
EOM

  agents.each do |agent|
    step "Agent #{agent}: create cache file with individual fact" do
      config_dir = get_default_fact_dir(agent['platform'],
                                        on(agent, facter("kernelmajversion #{@options[:trace]}")).stdout.chomp.to_f)
      config_file = File.join(config_dir, "facter.conf")
      cached_facts_dir = get_cached_facts_dir(agent['platform'],
                                              on(agent, facter("kernelmajversion #{@options[:trace]}")).stdout.chomp.to_f)

      cached_fact_file = File.join(cached_facts_dir, cached_fact_name)

      # Setup facter conf
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config)

      teardown do
        agent.rm_rf(config_dir)
        agent.rm_rf(cached_facts_dir)
      end

      step "should create a JSON file for a fact that is to be cached" do
        agent.rm_rf(cached_facts_dir)
        on(agent, facter("--debug #{@options[:trace]}")) do |facter_output|
          assert_match(/caching values for .+ facts/, facter_output.stderr, "Expected debug message to state that values will be cached")
        end
        cat_output = agent.cat(cached_fact_file)
        assert_match(/#{cached_fact_name}/, cat_output.strip, "Expected cached fact file to contain fact information")
      end

      step "should read from a cached JSON file for a fact that has been cached" do
        agent.mkdir_p(cached_facts_dir)
        create_remote_file(agent, cached_fact_file, cached_fact_content)

        on(agent, facter("#{cached_fact_name} --debug #{@options[:trace]}")) do
          assert_match(/loading cached values for .+ facts/, stderr, "Expected debug message to state that values are read from cache")
          assert_match(/#{cached_fact_value}/, stdout, "Expected fact to match the cached fact file")
        end
      end
    end
  end
end
