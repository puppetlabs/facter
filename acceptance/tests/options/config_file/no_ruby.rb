test_name "no-ruby config field flag disables requiring Ruby"
#
# This test is intended to demonstrate that the global.no-ruby config file field
# disables requiring Ruby and prevents custom fact lookup.
#
require 'facter/acceptance/user_fact_utils'
extend Facter::Acceptance::UserFactUtils

config = <<EOM
global : {
    no-ruby : true
}
EOM

custom_fact_content = <<EOM
Facter.add('custom_fact') do
  setcode do
    "testvalue"
  end
end
EOM

agents.each do |agent|
  step "Agent #{agent}: create config file"
  config_dir = agent.tmpdir("config_dir")
  config_file = File.join(config_dir, "facter.conf")
  create_remote_file(agent, config_file, config)

  step "no-ruby option should disable Ruby and facts requiring Ruby"
  on(agent, facter("--config '#{config_file}' ruby")) do
    assert_equal("", stdout.chomp, "Expected Ruby and Ruby fact to be disabled, but got output: #{stdout.chomp}")
    assert_equal("", stderr.chomp, "Expected no warnings about Ruby on stderr, but got output: #{stderr.chomp}")
  end

  step "no-ruby option should disable custom facts"
  custom_dir = get_user_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

  step "Agent #{agent}: create custom fact directory and custom fact"
  on(agent, "mkdir -p '#{custom_dir}'")
  custom_fact = File.join(custom_dir, 'custom_fact.rb')
  create_remote_file(agent, custom_fact, custom_fact_content)

  on(agent, facter("--config '#{config_file}' custom_fact", :environment => { 'FACTERLIB' => custom_dir })) do
    assert_equal("", stdout.chomp, "Expected custom fact to be disabled when no-ruby is true, but it resolved as #{stdout.chomp}")
  end
end
