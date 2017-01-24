test_name "#22944: Facter executes external executable facts many times"

require 'facter/acceptance/user_fact_utils'
extend ::Facter::Acceptance::UserFactUtils

agents.each do |agent|
  step "Agent #{agent}: create external executable fact"

  factsd = get_factsd_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
  ext = get_external_fact_script_extension(agent['platform'])

  if agent['platform'] =~ /windows/
    content = <<EOM
echo "SCRIPT CALLED" >&2
echo "test=value"
EOM
  else
    content = <<EOM
#!/bin/sh
echo "SCRIPT CALLED" >&2
echo "test=value"
EOM
  end

  step "Agent #{agent}: create facts.d directory"
  on(agent, "mkdir -p '#{factsd}'")

  step "Agent #{agent}: create external fact"
  ext_fact = "#{factsd}/external_fact#{ext}"

  teardown do
    on(agent, "rm -f '#{ext_fact}'")
  end

  create_remote_file(agent, ext_fact, content)

  step "Agent #{agent}: make it executable"
  on(agent, "chmod +x '#{ext_fact}'")

  step "Agent #{agent}: ensure it only executes once"
  on(agent, facter) do
    lines = stderr.split('\n')
    times = lines.count { |line| line =~ /SCRIPT CALLED/ }
    if times == 1
      step "External executable fact executed once"
    else
      fail_test "External fact executed #{times} times, expected once: #{stderr}"
    end
  end
end
