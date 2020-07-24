test_name "C100154: --external-dir fact overrides fact in default facts.d directory" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    os_version = on(agent, facter('kernelmajversion')).stdout.chomp.to_f
    ext = get_external_fact_script_extension(agent['platform'])
    factsd = get_factsd_dir(agent['platform'], os_version)
    external_dir = agent.tmpdir('facts.d')
    fact_file = File.join(factsd, "external_fact#{ext}")
    content = external_fact_content(agent['platform'], 'external_fact', 'value')
    override_fact_file = File.join(external_dir, "external_fact#{ext}")
    override_content = external_fact_content(agent['platform'], 'external_fact', 'OVERRIDE_value')

    teardown do
      agent.rm_rf(fact_file)
      agent.rm_rf(override_fact_file)
    end

    step "Agent #{agent}: setup default external facts directories and the test facts" do
      agent.mkdir_p(factsd)
      create_remote_file(agent, fact_file, content)
      create_remote_file(agent, override_fact_file, override_content)
      agent.chmod('+x', fact_file)
      agent.chmod('+x', override_fact_file)
    end

    step "Agent #{agent}: the fact value from the custom external dir should override that of facts.d" do
      on(agent, facter("--external-dir \"#{external_dir}\" external_fact")) do |facter_output|
        assert_equal('OVERRIDE_value', facter_output.stdout.chomp, 'Expected to resolve override version of the external_fact')
      end
    end
  end
end
