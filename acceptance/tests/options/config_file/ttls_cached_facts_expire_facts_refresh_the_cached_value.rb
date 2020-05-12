# This test verifies that cached facts that are expired are refreshed
test_name "C100040: ttls configured facts that are expired are refreshed" do
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

  cached_fact_value = "EXPIRED_CACHED_FACT_VALUE"
  cached_fact_content = <<EOM
{
  "#{cached_factname}": "#{cached_fact_value}"
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

      step "should refresh an expired cached fact" do
        # Setup a known cached fact
        agent.rm_rf(cached_facts_dir)
        on(agent, facter(""))
        create_remote_file(agent, cached_fact_file, cached_fact_content)
        # Change the modified date to sometime in the far distant past
        agent.modified_at(cached_fact_file, '198001010000')
        # Force facter to recache
        on(agent, facter("#{cached_factname}"))

        # Read cached fact file content
        on(agent, "cat #{cached_fact_file}", :acceptable_exit_codes => [0]) do |cat_output|
          assert_no_match(/#{cached_fact_value}/, cat_output.stdout, "Expected cached fact file to be refreshed")
        end
      end
    end
  end
end
