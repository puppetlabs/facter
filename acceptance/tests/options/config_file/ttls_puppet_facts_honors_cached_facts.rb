# Verify that setting a ttls, puppet facts returns the cached value of the fact
test_name "C100039: ttls configured cached facts run from puppet facts return cached facts" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  # This fact must be resolvable on ALL platforms
  # Do NOT use the 'kernel' fact as it is used to configure the tests
  cached_factname = 'system_uptime.uptime'
  config = <<EOM
facts : {
    ttls : [
        { "#{cached_factname}" : 30 days }
    ]
}
EOM

  cached_value = "CACHED_FACT_VALUE"
  cached_fact_content = <<EOM
{
  "#{cached_factname}": "#{cached_value}",
  "cache_format_version": 1
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
        agent.rm_rf(cached_facts_dir)
        agent.rm_rf(facter_conf_default_dir)
      end

      step "should read from a cached JSON file for a fact that has been cached" do
        step "call puppet facts to setup the cached fact" do
          agent.rm_rf(cached_facts_dir)
          on(agent, puppet("facts"))
          create_remote_file(agent, cached_fact_file, cached_fact_content)
        end

        on(agent, puppet("facts --debug")) do |puppet_facts_output|
          assert_match(/loading cached values for .+ facts/, puppet_facts_output.stdout, "Expected debug message to state that values are read from cache")
          assert_match(/#{cached_value}/, puppet_facts_output.stdout, "Expected fact to match the cached fact file")
        end
      end
    end
  end
end
