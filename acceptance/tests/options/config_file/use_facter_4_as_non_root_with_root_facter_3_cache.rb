test_name 'running facter 4 as non-root while facter 3 cache file owned by root exists(FACT-2961)' do
  tag 'risk:high'

  confine :except, :platform => 'windows' # this test currently only supported on unix systems FACT-1647
  confine :except, :platform => 'aix' # system su(1) command prints errors cannot access parent directories and ticket FACT-1586
  confine :except, :platform => 'osx' # system su(1) command prints errors cannot access parent directories
  confine :except, :platform => 'solaris' # system su(1) command prints errors cannot access parent directories

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  fact_group_name = 'uptime'
  config_data = <<~HOCON
    facts : {
      ttls : [
          { "#{fact_group_name}" : 3 days }
      ]
    }
  HOCON

  f3_cache = <<~JSON
    {
      "system_uptime": {
        "days": 1,
        "hours": 1,
        "seconds": 1,
        "uptime": "1 day"
      },
      "uptime": "1 days",
      "uptime_days": 1,
      "uptime_hours": 1,
      "uptime_seconds": 1
    }
  JSON

  # since facter is using beaker on localhost, stdin is not connected
  # and the only way to execute a manifest with puppet is by using
  # `-e "<MANIFEST>"` argument in command line, needing extra-escape
  # for quotes in manifests containing quotes
  config_data.gsub!('"','\"')
  f3_cache.gsub!('"','\"')

  agents.each do |agent|
    kernelmajversion = on(agent, facter('kernelmajversion')).stdout.chomp.to_f

    cache_dir = get_cached_facts_dir(agent['platform'], kernelmajversion)
    f3_cache_file = File.join(cache_dir, fact_group_name)

    f3_cache_file_manifest = <<-MANIFEST
file { '#{cache_dir}':
  ensure => 'directory',
  mode => '755'
}
file { '#{f3_cache_file}':
  content => '#{f3_cache}'
}
MANIFEST

    config_dir = get_default_fact_dir(agent['platform'], kernelmajversion)
    config_file = File.join(config_dir, 'facter.conf')

    config_file_manifest =  <<-MANIFEST
file { '#{config_file}':
  content => '#{config_data}'
}
MANIFEST

    non_root_user = "nonroot"
    facter_path = agent.which('facter').chomp

    teardown do
      agent.rm_rf(cache_dir)
      agent.rm_rf(config_dir)
      on(agent, puppet("resource user #{non_root_user} ensure=absent"))
    end

    step 'create cache file and the non-root account' do
      agent.mkdir_p(cache_dir)
      on(agent, puppet('apply', '--debug', "-e \" #{f3_cache_file_manifest} \""))
      on(agent, "puppet resource user #{non_root_user} ensure=present shell='#{user_shell(agent)}'")
    end

    step 'calling facter 4 as non-root user without config will show no error' do
      on(agent, %Q[su #{non_root_user} -c "'#{facter_path}' uptime"]) do |facter_results|
        assert_empty(facter_results.stderr.chomp, "Expected no errors from facter when run as user #{non_root_user}")
      end
    end

    step "Agent #{agent}: create config file to enable cache" do
      agent.mkdir_p(config_dir)
      on(agent, puppet('apply', '--debug', "-e \" #{config_file_manifest} \""))
    end

    step 'calling facter 4 as non-root user with config will print warning that cannot update cache file' do
      on(agent, %Q[su #{non_root_user} -c "'#{facter_path}' uptime"]) do |facter_results|
        assert_match(/WARN.*Could not delete cache: Permission denied/, facter_results.stderr, "Expected cache related permission denied warning #{non_root_user}")
      end
    end
  end
end
