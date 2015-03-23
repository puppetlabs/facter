test_name "custom fact commandline options (--no-custom-facts and --custom-dir)"

content = <<EOM
Facter.add('custom_fact') do
  setcode do
    "testvalue"
  end
end
EOM

agents.each do |agent|
  if agent['platform'] =~ /windows/
    if on(agent, cfacter('kernelmajversion')).stdout.chomp.to_f < 6.0
      custom_dir = 'C:/Documents and Settings/All Users/Application Data/PuppetLabs/facter/custom'
    else
      custom_dir = 'C:/ProgramData/PuppetLabs/facter/custom'
    end
  else
    custom_dir  = '/opt/puppetlabs/facter/custom'
  end

  step "Agent #{agent}: create custom fact directory and executable custom fact"
  on(agent, "mkdir -p '#{custom_dir}'")
  custom_fact = "#{custom_dir}/custom_fact.rb"
  create_remote_file(agent, custom_fact, content)
  on(agent, "chmod +x #{custom_fact}")

  teardown do
    on(agent, "rm -f '#{custom_fact}'")
  end

  step "--no-custom-facts option should disable custom facts"
  on(agent, "FACTERLIB=#{custom_dir} cfacter --no-custom-facts custom_fact") do
    assert_equal("", stdout.chomp, "Expected custom fact to be disabled, but it resolved as #{stdout.chomp}")
  end

  step "--custom-dir option should allow custom facts to be resolved from a specific directory"
  on(agent, "cfacter --custom-dir #{custom_dir} custom_fact") do
    assert_equal("testvalue", stdout.chomp, "Custom fact output does not match expected output")
  end
end
