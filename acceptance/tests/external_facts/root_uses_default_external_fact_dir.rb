# facter resolves facts from the default facts.d directory
# on Unix this can be 3 directories (See fact_directory_precedence.rb)
# Unix - /opt/puppetlabs/facter/facts.d/
# Windows - C:\ProgramData\PuppetLabs\facter\facts.d\
test_name "C87571: facter resolves facts in the default facts.d directory" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    os_version = on(agent, facter("kernelmajversion #{@options[:trace]}")).stdout.chomp.to_f
    ext = get_external_fact_script_extension(agent['platform'])
    factsd = get_factsd_dir(agent['platform'], os_version)
    fact_file = File.join(factsd, "external_fact_1#{ext}")
    content = external_fact_content(agent['platform'], 'external_fact', 'external_value')

    teardown do
      agent.rm_rf(fact_file)
    end

    step "Agent #{agent}: setup default external facts directory and fact" do
      agent.mkdir_p(factsd)
      create_remote_file(agent, fact_file, content)
      agent.chmod('+x', fact_file)
    end

    step "agent #{agent}: resolve the external fact" do
      on(agent, facter("external_fact #{@options[:trace]}")) do |facter_output|
        assert_equal('external_value', facter_output.stdout.chomp, 'Expected to resolve the external_fact')
      end
    end
  end
end
