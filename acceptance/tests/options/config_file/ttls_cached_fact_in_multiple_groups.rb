# This test verifies that individual facts can be cached
test_name "ttls config with fact in multiple groups should not cache fact twice" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  # This fact must be resolvable on ALL platforms
  # Do NOT use the 'kernel' fact as it is used to configure the tests
  cached_fact_name = 'os.name'
  first_fact_group = 'first'
  second_fact_group = 'second'

  config = <<EOM
facts : {
  ttls : [
      { "#{first_fact_group}" : 30 days },
      { "#{second_fact_group}" : 1 days },
  ]
}
fact-groups : {
  #{first_fact_group}: [#{cached_fact_name}],
  #{second_fact_group}: ["os"],
}
EOM

  agents.each do |agent|
    step "Agent #{agent}: create cache file with individual fact" do
      config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      config_file = File.join(config_dir, "facter.conf")
      cached_facts_dir = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

      first_cached_fact_file = File.join(cached_facts_dir, first_fact_group)
      second_cached_fact_file = File.join(cached_facts_dir, second_fact_group)

      # Setup facter conf
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config)

      teardown do
        agent.rm_rf(config_dir)
        agent.rm_rf(cached_facts_dir)
      end

      step "should create a JSON file for a fact that is to be cached" do
        agent.rm_rf(cached_facts_dir)
        on(agent, facter("--debug")) do |facter_output|
          assert_match(/caching values for .+ facts/, facter_output.stderr, "Expected debug message to state that values will be cached")
        end
        first_cat_output = agent.cat(first_cached_fact_file)
        assert_match(/#{cached_fact_name}/, first_cat_output.strip, "Expected cached fact file to contain fact information")
        second_cat_output = agent.cat(second_cached_fact_file)
        assert_not_match(/#{cached_fact_name}/, second_cat_output.strip, "Expected cached fact file to not contain fact information")
      end
    end
  end
end
