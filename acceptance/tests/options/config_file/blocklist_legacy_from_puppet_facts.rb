# frozen_string_literal: true

# This test verifies that when a legacy fact group is blocked in the config file the
# corresponding facts do not resolve when being run from the puppet facts command.
test_name 'when run from puppet facts, legacy facts can be blocked via a list in the config file' do
  tag 'risk:medium'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    step 'facts should be blocked when Facter is run from Puppet with a configured blocklist' do
      # default facter.conf
      facter_conf_default_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      facter_conf_default_path = File.join(facter_conf_default_dir, 'facter.conf')

      teardown do
        on(agent, "rm -rf '#{facter_conf_default_dir}'", acceptable_exit_codes: [0, 1])
      end

      step "Agent #{agent}: create default config file" do
        # create the directories
        on(agent, "mkdir -p '#{facter_conf_default_dir}'")
        create_remote_file(agent, facter_conf_default_path, <<-FILE)
        facts : { blocklist : [ "legacy" ] }
        FILE
      end

      step 'blocked legacy facts should not be shown in output' do
        on(agent, puppet('facts')) do |puppet_facts_output|
          assert_no_match(
            /operatingsystem/,
            puppet_facts_output.stdout,
            'operatingsystem legacy fact should have been blocked'
          )
        end
      end
    end
  end
end
