# This test verifies that a ttls configured cached facts when initially called
# create a json cache file
test_name "ttls configured cached external text resolver creates and read json cache files" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  # This fact must be resolvable on ALL platforms
  # Do NOT use the 'kernel' fact as it is used to configure the tests
  external_cachegroup = 'external_fact'
  cached_fact_name = 'single_fact'
  initial_fact_value = 'initial_external_value'
  cached_fact_value = 'cached_external_value'

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      external_dir = agent.tmpdir('external_dir')
      ext = '.txt'
      external_fact = File.join(external_dir, "#{external_cachegroup}#{ext}")

      external_fact_content = <<EOM
#{cached_fact_name}=#{initial_fact_value}
EOM

      create_remote_file(agent, external_fact, external_fact_content)

      config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      config_file = File.join(config_dir, "facter.conf")
      cached_facts_dir = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

      cached_fact_file = File.join(cached_facts_dir, "#{external_cachegroup}#{ext}")

      # Setup facter conf
      agent.mkdir_p(config_dir)
      cached_fact_content = <<EOM
{
  "#{cached_fact_name}": "#{cached_fact_value}",
  "cache_format_version": 1
}
EOM

      config = <<EOM
facts : {
    ttls : [
        { "#{external_cachegroup}#{ext}" : 30 days }
    ]
}
EOM
      create_remote_file(agent, config_file, config)

      teardown do
        agent.rm_rf(config_dir)
        agent.rm_rf(cached_facts_dir)
        agent.rm_rf(external_dir)
      end

      step "should create a JSON file for a fact that is to be cached" do
        agent.rm_rf(cached_facts_dir)
        on(agent, facter("--external-dir \"#{external_dir}\" --debug #{cached_fact_name}")) do |facter_output|
          assert_match(/caching values for .+ facts/, facter_output.stderr, "Expected debug message to state that values will be cached")
        end
        cat_output = agent.cat(cached_fact_file)
        assert_match(/#{cached_fact_name}/, cat_output.strip, "Expected cached fact file to contain fact information")
      end

      step "should read from a cached JSON file for a fact that has been cached" do
        agent.rm_rf(cached_facts_dir)
        on(agent, facter("--external-dir \"#{external_dir}\" --debug #{cached_fact_name}"))

        create_remote_file(agent, cached_fact_file, cached_fact_content)

        on(agent, facter("--external-dir \"#{external_dir}\" --debug #{cached_fact_name}")) do |facter_output|
          assert_match(/loading cached values for .+ facts/, stderr, "Expected debug message to state that values are read from cache")
          assert_match(/#{cached_fact_value}/, stdout, "Expected fact to match the cached fact file")
        end
      end
    end
  end
end
