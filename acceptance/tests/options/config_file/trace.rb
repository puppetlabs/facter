# This test is intended to demonstrate that setting the cli.trace field to true
# enables backtrace reporting for errors in custom facts.
test_name "trace config field enables backtraces for custom facts" do
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  erroring_custom_fact = <<EOM
Facter.add('custom_fact') do
  setcode do
    non_existent_value
  end
end
EOM

  config = <<EOM
cli : {
    trace : true
}
EOM

  agents.each do |agent|
    step "Agent #{agent}: create custom fact directory and executable custom fact" do
      custom_dir = get_user_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      on(agent, "mkdir -p '#{custom_dir}'")
      custom_fact = File.join(custom_dir, "custom_fact.rb")
      create_remote_file(agent, custom_fact, erroring_custom_fact)
      on(agent, "chmod +x '#{custom_fact}'")

      config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      config_file = File.join(config_dir, "facter.conf")
      on(agent, "mkdir -p '#{config_dir}'")
      create_remote_file(agent, config_file, config)

      teardown do
        on(agent, "rm -rf '#{custom_dir}' '#{config_dir}'", :acceptable_exit_codes => [0,1])
      end

      step "trace setting should provide a backtrace for a custom fact with errors" do
        on(agent, facter("--custom-dir '#{custom_dir}' custom_fact"), :acceptable_exit_codes => [1])
        assert_match(/backtrace:\s+#{custom_fact}/, stderr, "Expected a backtrace for erroneous custom fact")
      end
    end
  end
end

