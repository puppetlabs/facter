# These tests are intended to ensure that the --no-ruby command-line option
# works properly. The first ensures that the built in Ruby fact does not resolve
# when using the --no-ruby fact, and also checks that the 'No Ruby' warning does
# not appear in stderr. The second test ensures that custom facts are not resolved
# when the --no-ruby option is present.
test_name "--no-ruby commandline option" do

  require 'facter/acceptance/user_fact_utils'
  extend ::Facter::Acceptance::UserFactUtils

  content = <<EOM
Facter.add('custom_fact') do
  setcode do
    "testvalue"
  end
end
EOM

  agents.each do |agent|
    step "--no-ruby option should disable Ruby and facts requiring ruby from being loaded" do
      on(agent, facter("--no-ruby ruby")) do
        assert_equal("", stdout.chomp, "Expected Ruby and Ruby fact to be disabled, but got output: #{stdout.chomp}")
        assert_equal("", stderr.chomp, "Expected no warnings about Ruby on stderr, but got output: #{stderr.chomp}")
      end
    end

    step "--no-ruby option should disable custom facts" do
      step "Agent #{agent}: create custom fact directory and custom fact" do
        custom_dir = get_user_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
        on(agent, "mkdir -p '#{custom_dir}'")
        custom_fact = File.join(custom_dir, 'custom_fact.rb')
        create_remote_file(agent, custom_fact, content)

        on(agent, facter('--no-ruby custom_fact', :environment => { 'FACTERLIB' => custom_dir })) do
          assert_equal("", stdout.chomp, "Expected custom fact to be disabled while using --no-ruby option, but it resolved as #{stdout.chomp}")
        end
      end
    end
  end
end
