test_name "#22944: Facter executes external executable facts many times"

unix_content = <<EOM
#!/bin/sh
echo "SCRIPT CALLED" >&2
echo "test=value"
EOM

win_content = <<EOM
echo "SCRIPT CALLED" >&2
echo "test=value"
EOM

agents.each do |agent|
  step "Agent #{agent}: create external executable fact"

  # assume we're running as root
  if agent['platform'] =~ /windows/
    if on(agent, facter('kernelmajversion')).stdout.chomp.to_f < 6.0
      factsd = 'C:/Documents and Settings/All Users/Application Data/PuppetLabs/facter/facts.d'
    else
      factsd = 'C:/ProgramData/PuppetLabs/facter/facts.d'
    end
    ext = '.bat'
    content = win_content
  else
    factsd = '/opt/puppetlabs/facter/facts.d'
    ext = '.sh'
    content = unix_content
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
