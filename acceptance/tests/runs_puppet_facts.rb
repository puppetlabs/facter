test_name "facter -p loads facts from puppet"

agents.each do |agent|
  external_dir = agent.puppet['pluginfactdest']
  external_file = "#{external_dir}/external.txt"
  custom_dir = agent.puppet['plugindest']
  custom_dir += "/facter"
  custom_file = "#{custom_dir}/custom.rb"

  teardown do
    on agent, "rm -f '#{external_file}' '#{custom_file}'"
  end

  step "Agent #{agent}: create external fact"
  on agent, "mkdir -p '#{external_dir}'"
  create_remote_file(agent, external_file, "external=external")

  step "Agent #{agent}: create custom fact"
  on agent, "mkdir -p '#{custom_dir}'"
  create_remote_file(agent, custom_file, "Facter.add(:custom) { setcode { 'custom' } }")

  step "Agent #{agent}: verify facts"
  on(agent, facter("-p external")) do
    assert_equal("external", stdout.chomp)
  end

  on(agent, facter("-p custom")) do
    assert_equal("custom", stdout.chomp)
  end
end
