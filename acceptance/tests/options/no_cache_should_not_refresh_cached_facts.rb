# This test is intended to verify that the `--no-cache` command line flag will
# cause facter to not refresh a cached fact that is expired
test_name "C100124: --no-cache does not refresh expired cached facts" do
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

    step "facter should not refresh an expired cache when --no-cache is specified" do
      # clear the fact cache
      agent.rm_rf(cached_facts_dir)

      # run once to cache the uptime fact
      on(agent, facter(""))

      # override cached content
      create_remote_file(agent, cached_fact_file, bad_cached_content)
      # update the modify time on the new cached fact to prompt a refresh
      agent.modified_at(cached_fact_file, '198001010000')

      on(agent, facter("--no-cache")) do |facter_output|
        assert_no_match(/caching/, facter_output.stderr, "facter should not have tried to refresh the cache")
      end

      cat_output = agent.cat(cached_fact_file)
      assert_match(/#{bad_cached_content.chomp}/, cat_output.strip, "facter should not have updated the cached value")
    end
  end
end
