# This test is intended to verify that the `--no-cache` command line flag will
# cause facter to not do any caching of facts
test_name "C99968: --no-cache command-line option causes facter to not cache facts" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  # the uptime fact should be resolvable on ALL systems
  # Note: do NOT use the kernel fact, as it is used to configure the tests
  cached_fact_name = "uptime"
  config = <<-FILE
  cli : { debug : true }
  facts : { ttls : [ { "#{cached_fact_name}" : 30 minutes } ] }
  FILE

  agents.each do |agent|
    kernel_version = on(agent, facter('kernelmajversion')).stdout.chomp.to_f
    config_dir = get_default_fact_dir(agent['platform'], kernel_version)
    config_file = File.join(config_dir, "facter.conf")

    cached_facts_dir = get_cached_facts_dir(agent['platform'], kernel_version)
    cached_fact_file = File.join(cached_facts_dir, cached_fact_name)

    on(agent, "rm -f '#{cached_fact_file}'", :acceptable_exit_codes => [0, 1])

    teardown do
      on(agent, "rm -rf '#{config_dir}'", :acceptable_exit_codes => [0, 1])
      on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0, 1])
    end

    step "Agent #{agent}: create config file in default location" do
      on(agent, "mkdir -p '#{config_dir}'")
      create_remote_file(agent, config_file, config)
    end

    step "facter should not cache facts when --no-cache is specified" do
      on(agent, facter("--no-cache")) do |facter_output|
        assert_no_match(/caching/, facter_output.stderr, "facter should not have tried to cache any facts")
      end
    end
  end
end
