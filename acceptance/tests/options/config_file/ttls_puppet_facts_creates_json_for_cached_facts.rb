# Verify that setting a ttls, creates a json file for the cached fact when run
# from puppet facts
test_name "C100038: with ttls configured create cached facts when run from puppet facts" do
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
      facter_conf_default_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      facter_conf_default_path = File.join(facter_conf_default_dir, "facter.conf")
      cached_facts_dir = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      cached_fact_file = File.join(cached_facts_dir, cached_factname)

      agent.mkdir_p(facter_conf_default_dir)
      create_remote_file(agent, facter_conf_default_path, config)

      teardown do
        agent.rm_rf(facter_conf_default_dir)
        agent.rm_rf(cached_facts_dir)
      end

      step "should create a JSON file for a fact that is to be cached" do
        agent.rm_rf(cached_facts_dir)
        on(agent, puppet("facts --debug")) do |pupppet_fact_output|
          assert_match(/caching values for .+ facts/, pupppet_fact_output.stdout, "Expected debug message to state that values will be cached")
        end
        cat_output = agent.cat(cached_fact_file)
        assert_match(/#{cached_factname}/, cat_output.strip, "Expected cached fact file to contain fact information")
      end
    end
  end
end
