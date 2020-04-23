# This test verifies that expired cached facts are not used
test_name "C100037: ttls configured cached valued that are expired are not returned" do
  tag 'risk:high'

  confine :to, :platform => /Skipped/

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
      config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      config_file = File.join(config_dir, "facter.conf")
      cached_facts_dir = get_cached_facts_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

      cached_fact_file = File.join(cached_facts_dir, cached_factname)

      # Setup facter conf
      on(agent, "mkdir -p '#{config_dir}'")
      create_remote_file(agent, config_file, config)

      teardown do
        on(agent, "rm -rf '#{config_dir}'", :acceptable_exit_codes => [0, 1])
        on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0, 1])
      end

      step "should not read from a cached JSON file for a fact that has been cached but the TTL expired" do
        # Setup a known cached fact
        on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0, 1])
        on(agent, facter(""))
        create_remote_file(agent, cached_fact_file, cached_fact_content)
        # Change the modified date to sometime in the far distant past
        on(agent, "touch -mt 198001010000 '#{cached_fact_file}'")

        on(agent, facter("#{cached_factname}")) do |facter_output|
          assert_not_match(/#{cached_fact_value}/, facter_output.stdout, "Expected fact to not match the cached fact file")
        end
      end
    end
  end
end
