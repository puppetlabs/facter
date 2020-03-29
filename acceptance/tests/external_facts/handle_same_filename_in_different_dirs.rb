# Verify how facter handles same external facts filename in different directories:
#
#     - in case ttl not enabled, will accept same filename in two external directories
#     - in case ttl enabled on filename, will throw error and exit 1
#

test_name 'Should handle same filename in two external directories only if ttl is not enabled' do
  tag 'risk:high'

  confine :to, :platform => /Skipped/

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    fact1 = 'fact1'
    fact2 = 'fact2'
    fact1_value = 'fact1_value'
    fact2_value = 'fact2_value'
    external_filename = 'text.yaml'
    external_dir1 = agent.tmpdir('external_dir')
    external_fact_file1 = File.join(external_dir1, external_filename)
    external_dir2 = agent.tmpdir('external_dir')
    external_fact_file2 = File.join(external_dir2, external_filename)
    create_remote_file(agent, external_fact_file1, "#{fact1}: #{fact1_value}")
    create_remote_file(agent, external_fact_file2, "#{fact2}: #{fact2_value}")

    config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    config_file = File.join(config_dir, 'facter.conf')

    teardown do
      on(agent, "rm -rf '#{external_dir1}' '#{external_dir2}' '#{config_file}'")
    end

    step 'works if ttl is not enabled' do
      on(agent, facter("--external-dir '#{external_dir1}' --external-dir '#{external_dir2}' --debug #{fact1} #{fact2}")) do |facter_output|
        assert_match(/#{fact1} => #{fact1_value}/, stdout, 'Expected fact to match first fact')
        assert_match(/#{fact2} => #{fact2_value}/, stdout, 'Expected fact to match second fact')
      end
    end

    step 'does not work if ttl is enabled' do
      config = <<EOM
facts : {
    ttls : [
        { "#{external_filename}" : 30 days }
    ]
}
EOM
      on(agent, "mkdir -p '#{config_dir}'")
      create_remote_file(agent, config_file, config)
      on(agent, facter("--external-dir '#{external_dir1}' --external-dir '#{external_dir2}' --debug #{fact1} #{fact2}"), :acceptable_exit_codes => 1) do |facter_output|
        assert_match(/ERROR.*Caching is enabled for group "#{external_filename}" while there are at least two external facts files with the same filename/, stderr, 'Expected error message')
        assert_match(/#{fact1} => #{fact1_value}/, stdout, 'Expected fact to match first fact')
        assert_not_match(/#{fact2} => #{fact2_value}/, stdout, 'Expected fact not to match second fact')
      end
    end


  end
end
