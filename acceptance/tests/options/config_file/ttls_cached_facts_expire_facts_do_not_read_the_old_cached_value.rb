# This test verifies that expired cached facts are not used
test_name "C100037: ttls configured cached valued that are expired are not returned" do
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

  cached_fact_value = "CACHED_FACT_VALUE"
  cached_fact_content = <<EOM
{
  "#{cached_factname}": "#{cached_fact_value}"
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

      step "should not read from a cached JSON file for a fact that has been cached but the TTL expired" do
        # Setup a known cached fact
        agent.rm_rf(cached_facts_dir)
        on(agent, facter("#{@options[:trace]}"))
        create_remote_file(agent, cached_fact_file, cached_fact_content)
        # Change the modified date to sometime in the far distant past
        agent.modified_at(cached_fact_file, '198001010000')

        on(agent, facter("#{cached_factname} #{@options[:trace]}")) do |facter_output|
          assert_not_match(/#{cached_fact_value}/, facter_output.stdout, "Expected fact to not match the cached fact file")
        end
      end
    end
  end
end
