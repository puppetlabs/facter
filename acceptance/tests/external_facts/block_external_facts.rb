test_name 'custom facts included in blocklist will not be displayed' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    ext = get_external_fact_script_extension(agent['platform'])
    facts_dir = agent.tmpdir('facts.d')
    fact_file = File.join(facts_dir, "external_fact_1#{ext}")
    content = external_fact_content(agent['platform'], 'external_fact', 'external_value')

    config_dir = agent.tmpdir("config_dir")
    config_file = File.join(config_dir, "facter.conf")

    teardown do
      agent.rm_rf(facts_dir)
    end

    create_remote_file(agent, config_file, <<-FILE)
      facts : { blocklist : [ "external_fact_1#{ext}" ] }
      FILE

    step "Agent #{agent}: setup default external facts directory and fact" do
      agent.mkdir_p(facts_dir)
      create_remote_file(agent, fact_file, content)
      agent.chmod('+x', fact_file)
    end

    step "agent #{agent}: resolve the external fact" do
      facter_command = "--debug --external-dir \"#{facts_dir}\" --config \"#{config_file}\" #{@options[:trace]}"
      on(agent, facter(facter_command)) do |facter_output|
        assert_match(/External fact file external_fact_1#{ext} blocked./, facter_output.stderr.chomp, 'Expected to block the external_fact')
        assert_no_match(/external_fact => external_value/, stdout, 'Expected fact not to match fact')
      end
    end
  end
end
