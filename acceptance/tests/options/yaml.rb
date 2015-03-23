require 'yaml'

test_name "--yaml command-line option results in valid YAML output"

content = <<EOM
Facter.add('structured_fact') do
  setcode do
    { "foo" => {"nested" => "value1"}, "bar" => "value2", "baz" => "value3" }
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

  step "Agent #{agent}: create a structured custom fact"
  custom_fact = "#{custom_dir}/custom_fact.rb"
  on(agent, "mkdir -p '#{custom_dir}'")
  create_remote_file(agent, custom_fact, content)
  on(agent, "chmod +x #{custom_fact}")

  teardown do
    on(agent, "rm -f '#{custom_fact}'")
  end

  step "Agent #{agent}: retrieve output using the --yaml option"
  on(agent, "FACTERLIB=#{custom_dir} cfacter structured_fact --yaml") do
    begin
      expected = {"structured_fact" => {"foo" => {"nested" => "value1"}, "bar" => "value2", "baz" => "value3" }}.to_yaml.gsub("---\n", '')
      assert_equal(expected, stdout, "YAML output does not match expected output")
    rescue
      fail_test "Couldn't parse output as YAML"
    end
  end
end
