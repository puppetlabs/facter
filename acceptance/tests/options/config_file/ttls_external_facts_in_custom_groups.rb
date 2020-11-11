test_name "ttls configured cached with external in custom group prints error" do
  tag 'risk:high'

  skip_test "WIP"

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  # This fact must be resolvable on ALL platforms
  # Do NOT use the 'kernel' fact as it is used to configure the tests
  external_cachegroup = 'external_fact_group'
  cached_fact_name = 'external_fact'
  fact_value = 'initial_external_value'

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      external_dir = agent.tmpdir('external_dir')
      ext = '.txt'
      external_fact = File.join(external_dir, "#{cached_fact_name}#{ext}")

      external_fact_content = <<EOM
#{cached_fact_name}=#{fact_value}
EOM

      create_remote_file(agent, external_fact, external_fact_content)

      config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      config_file = File.join(config_dir, "facter.conf")

      # Setup facter conf
      agent.mkdir_p(config_dir)

      config = <<EOM
facts : {
    ttls : [
        { "#{external_cachegroup}" : 30 days }
    ]
}

fact-groups : {
  "#{external_cachegroup}" : ["#{cached_fact_name}#{ext}"],
}
EOM
      create_remote_file(agent, config_file, config)

      teardown do
        agent.rm_rf(config_dir)
        agent.rm_rf(cached_facts_dir)
        agent.rm_rf(external_dir)
      end

      step "should print error and not cache anything" do
        on(agent, facter("--external-dir \"#{external_dir}\" --debug #{cached_fact_name}"), acceptable_exit_codes: [1]) do |facter_output|
          assert_match(/Caching custom group is not supported for external facts/, facter_output.stderr, "Expected error message to state that external facts cannot be grouped")
        end
      end
    end
  end
end
