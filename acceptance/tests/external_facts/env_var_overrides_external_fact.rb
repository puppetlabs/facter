test_name 'C100537: FACTER_ env var should override external fact' do
  tag 'risk:medium'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    fact_name      = 'external_fact'
    fact_value     = 'from_script'
    override_value = 'override_fact'
    external_dir   = agent.tmpdir('facts.d')
    fact_file      = File.join(external_dir,
                               "#{fact_name}#{get_external_fact_script_extension(agent['platform'])}")

    teardown do
      on(agent, "rm -rf '#{external_dir}'")
    end

    step "Agent #{agent}: setup external fact" do
      on(agent, "mkdir -p '#{external_dir}'")
      create_remote_file(agent,
                         fact_file,
                         external_fact_content(agent['platform'], fact_name, fact_value))
      on(agent, "chmod +x '#{fact_file}'")
    end

    step "Agent: #{agent}: ensure external fact resolves correctly" do
      on(agent, facter("--external-dir '#{external_dir}' #{fact_name}")) do |facter_output|
        assert_equal(fact_value,
                     facter_output.stdout.chomp,
                     'Expected external fact to resolve as defined in script')
      end
    end

    step "Agent #{agent}: the fact value from FACTER_ env var should override the external fact value" do
      on(agent, facter("--external-dir '#{external_dir}' #{fact_name}",
                       :environment => { "FACTER_#{fact_name}" => override_value })) do |facter_output|
        assert_equal(override_value,
                     facter_output.stdout.chomp,
                     'Expected `FACTER_` fact value to override external fact')
      end
    end

  end

end
