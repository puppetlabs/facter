# This test is intended to verify that the `--no-cache` command line flag will
# cause the cache to be ignored. During a run with this flag, the cache will neither
# be queried nor refreshed.
test_name "C99968: --no-cache command-line option causes the fact cache to be ignored" do
  tag 'risk:medium'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  # the uptime fact should be resolvable on ALL systems
  # Note: do NOT use the kernel fact, as it is used to configure the tests
  cached_fact_name = "uptime"
  bad_cached_fact_value = "CACHED_FACT_VALUE"
  bad_cached_content = <<EOM
{ 
  "#{cached_fact_name}": "fake #{bad_cached_fact_value}"
}
EOM


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
        assert_no_match(/#{bad_cached_fact_value}/, facter_output.stdout, "facter should not have loaded the cached value")
      end
    end

    step "facter should not load facts from the cache when --no-cache is specified" do
      # clear the fact cache
      on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0, 1])

      # run once to cache the uptime fact
      on(agent, facter(""))
      # override cached content
      create_remote_file(agent, cached_fact_file, bad_cached_content)

      on(agent, facter("--no-cache #{cached_fact_name}")) do |facter_output|
        assert_no_match(/loading cached values for .+ fact/, facter_output.stderr, "facter should not have tried to load any cached facts")
        assert_no_match(/#{bad_cached_fact_value}/, facter_output.stdout, "facter should not have loaded the cached value")
      end
    end

    step "facter should not refresh an expired cache when --no-cache is specified" do
      # clear the fact cache
      on(agent, "rm -rf '#{cached_facts_dir}'", :acceptable_exit_codes => [0, 1])

      # run once to cache the uptime fact
      on(agent, facter(""))

      # override cached content
      create_remote_file(agent, cached_fact_file, bad_cached_content)
      # update the modify time on the new cached fact to prompt a refresh
      on(agent, "touch -mt 0301010000 '#{cached_fact_file}'")

      on(agent, facter("--no-cache")) do |facter_output|
        assert_no_match(/caching/, facter_output.stderr, "facter should not have tried to refresh the cache")
      end

      on(agent, "cat '#{cached_fact_file}'", :acceptable_exit_codes => [0]) do |cat_output|
        assert_match(/#{bad_cached_content}/, cat_output.stdout, "facter should not have updated the cached value")
      end
    end
  end
end
