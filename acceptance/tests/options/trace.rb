# This test is intended to ensure that the --trace command-line option works
# properly. This option provides backtraces for erroring custom Ruby facts.
# To test, we try to resolve an erroneous custom fact and catch the backtrace.
test_name "C99982: --trace command-line option enables backtraces for custom facts" do

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  content = <<EOM
Facter.add('custom_fact_trace') do
  setcode do
    non_existent_value
  end
end
EOM

  agents.each do |agent|
    step "Agent #{agent}: create custom fact directory and executable custom fact" do
      custom_dir = get_user_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      agent.mkdir_p(custom_dir)
      custom_fact = File.join(custom_dir, 'custom_fact.rb')
      create_remote_file(agent, custom_fact, content)
      agent.chmod('+x', custom_fact)

      teardown do
        agent.rm_rf(custom_fact)
      end

      step "--trace option should provide a backtrace for a custom fact with errors" do
        on(agent, facter("--custom-dir \"#{custom_dir}\" --trace custom_fact_trace"), :acceptable_exit_codes => [1]) do |facter_output|
          assert_match(/backtrace:\s+#{custom_fact}/, facter_output.stderr, "Expected a backtrace for erroneous custom fact")
        end
      end
    end
  end
end
