test_name "external fact commandline options (--no-external-facts and --external-dir)"

unix_content = <<EOM
#!/bin/sh
echo "external_fact=testvalue"
EOM

win_content = <<EOM
echo "external_fact=testvalue"
EOM

agents.each do |agent|
  if agent['platform'] =~ /windows/
    if on(agent, cfacter('kernelmajversion')).stdout.chomp.to_f < 6.0
      factsd = 'C:/Documents and Settings/All Users/Application Data/PuppetLabs/puppet/facts.d'
      custom_external_dir = 'C:/Documents and Settings/All Users/Application Data/PuppetLabs/facter/custom'
    else
      factsd = 'C:/ProgramData/PuppetLabs/puppet/facts.d'
      custom_external_dir = 'C:/ProgramData/PuppetLabs/facter/custom'
    end
    ext = '.bat'
    content = win_content
  else
    factsd = '/opt/puppetlabs/facter/facts.d'
    custom_external_dir = '/opt/puppetlabs/facter/custom'
    ext = '.sh'
    content = unix_content
  end

  step "Agent #{agent}: setup facts.d and custom external fact directories"
  on(agent, "mkdir -p '#{factsd}'")
  on(agent, "mkdir -p '#{custom_external_dir}'")

  step "Agent #{agent}: create executable external facts in facts.d and custom external fact dir"
  ext_fact_factsd     = "#{factsd}/external_fact#{ext}"
  ext_fact_custom_dir = "#{custom_external_dir}/external_fact#{ext}"
  create_remote_file(agent, ext_fact_factsd, content)
  create_remote_file(agent, ext_fact_custom_dir, content)
  on(agent, "chmod +x #{ext_fact_factsd} #{ext_fact_custom_dir}")

  teardown do
    on(agent, "rm -f '#{ext_fact_factsd} #{ext_fact_custom_dir}'")
  end

  step "--no-external-facts option should disable external facts"
  on(agent, "cfacter --no-external-facts external_fact") do
    assert_equal("", stdout.chomp, "Expected external fact to be disabled, but it resolved as #{stdout.chomp}")
  end

  step "--external-dir option should allow external facts to be resolved from a specific directory"
  on(agent, "cfacter --external-dir #{custom_external_dir} external_fact") do
    assert_equal("testvalue", stdout.chomp, "External fact output does not match expected output")
  end
end
