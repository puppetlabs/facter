test_name "--trace command-line option enables backtraces for custom facts"

require 'facter/acceptance/user_fact_utils'
extend Facter::Acceptance::UserFactUtils

#
# This test is intended to ensure that the --trace command-line option works
# properly. This option provides backtraces for erroring custom Ruby facts.
# To test, we try to resolve an erroneous custom fact and catch the backtrace.
#

content = <<EOM
Facter.add('custom_fact') do
  setcode do
    non_existent_value
  end
end
EOM

agents.each do |agent|
  custom_dir = get_user_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)

  step "Agent #{agent}: create custom fact directory and executable custom fact"
  on(agent, "mkdir -p '#{custom_dir}'")
  custom_fact = File.join(custom_dir, 'custom_fact.rb')
  create_remote_file(agent, custom_fact, content)
  on(agent, "chmod +x #{custom_fact}")

  teardown do
    on(agent, "rm -f '#{custom_fact}'")
  end

  step "--trace option should provide a backtrace for a custom fact with errors"
  begin
    on(agent, "FACTERLIB=#{custom_dir} facter --trace custom_fact")
  rescue Exception => e
    assert_match(/backtrace:\s+#{custom_fact}/, e.message, "Expected a backtrace for erroneous custom fact")
  end
end
