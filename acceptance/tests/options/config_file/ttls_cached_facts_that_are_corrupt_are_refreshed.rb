# This test verifies that corrupt facts are refreshed with new values
test_name "C100042: ttls configured cached facts that are corrupt are refreshed with new values" do
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
      config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      config_file = File.join(config_dir, "facter.conf")
      cached_facts_dir = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

      cached_fact_file = File.join(cached_facts_dir, cached_factname)

      # Setup facter conf
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config)

      teardown do
        agent.rm_rf(config_dir)
        agent.rm_rf(cached_facts_dir)
      end

      step "should refresh a cached fact if cache file is corrupt" do
        # Setup a known cached fact
        agent.rm_rf(cached_facts_dir)
        on(agent, facter(""))
        # Corrupt the cached fact file
        create_remote_file(agent, cached_fact_file, 'ThisIsNotvalidJSON')

        on(agent, facter("#{cached_factname}")) do |facter_output|
          assert_match(/.+/, facter_output.stdout, "Expected fact to be resolved")
        end
        cat_output = agent.cat(cached_fact_file)
        assert_match(/#{cached_factname}/, cat_output.strip, "Expected cachced fact to contain the fact name")
      end
    end
  end
end
