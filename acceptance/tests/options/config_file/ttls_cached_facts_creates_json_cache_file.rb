# This test verifies that a ttls configured cached facts when initially called
# create a json cache file
test_name "C99973: ttls configured cached facts create json cache files" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  # This fact must be resolvable on ALL platforms
  # Do NOT use the 'kernel' fact as it is used to configure the tests
  cached_factname = 'uptime'
  config = <<EOM
facts : {
    ttls : [
        { "#{cached_factname}" : 30 days }
    ]
}
EOM

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      config_dir = get_default_fact_dir(agent['platform'],
                                        on(agent, facter("kernelmajversion #{@options[:trace]}")).stdout.chomp.to_f)
      config_file = File.join(config_dir, "facter.conf")
      cached_facts_dir = get_cached_facts_dir(agent['platform'],
                                              on(agent, facter("kernelmajversion #{@options[:trace]}")).stdout.chomp.to_f)

      cached_fact_file = File.join(cached_facts_dir, cached_factname)

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
        assert_match(/#{cached_factname}/, cat_output.strip, "Expected cached fact file to contain fact information")
      end
    end
  end
end
