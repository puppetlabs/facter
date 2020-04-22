# This test is intended to verify that the `--no-cache` command line flag will
# cause facter to not load already cached facts
test_name "C100123: --no-cache command-line option does not load facts from the cache" do
  tag 'risk:high'

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
      agent.rm_rf(config_dir)
      agent.rm_rf(cached_facts_dir)
    end

    step "Agent #{agent}: create config file in default location" do
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config)
    end

    step "facter should not load facts from the cache when --no-cache is specified" do
      # clear the fact cache
      agent.rm_rf(cached_facts_dir)

      # run once to cache the uptime fact
      on(agent, facter(""))
      # override cached content
      create_remote_file(agent, cached_fact_file, bad_cached_content)

      on(agent, facter("--no-cache #{cached_fact_name}")) do |facter_output|
        assert_no_match(/loading cached values for .+ fact/, facter_output.stderr, "facter should not have tried to load any cached facts")
        assert_no_match(/#{bad_cached_fact_value}/, facter_output.stdout, "facter should not have loaded the cached value")
      end
    end
  end
end
