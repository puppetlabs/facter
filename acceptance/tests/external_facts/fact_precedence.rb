test_name "Fact precedence and resolution order (external & custom facts)"

require 'facter/acceptance/user_fact_utils'
extend ::Facter::Acceptance::UserFactUtils

# Use a static external fact
ext_fact = "test: 'EXTERNAL'"

# Generate custom fact dynamically
def cust_fact(*args)
  <<-EOM
  Facter.add('test') do
    setcode {'CUSTOM'}
    #{args.empty? ? '':args.join('\n')}
  end
  EOM
end

agents.each do |agent|
  # Shared directory for external and custom facts
  facts_dir = agent.tmpdir('facts.d')
  ext_fact_path = "#{facts_dir}/test.yaml"
  cust_fact_path = "#{facts_dir}/test.rb"

  step "Agent #{agent}: create facts directory (#{facts_dir})"
  on(agent, "rm -rf #{facts_dir}")
  on(agent, "mkdir -p #{facts_dir}")

  # Custom fact with no external fact should resolve to CUSTOM
  step "Agent #{agent}: create and resolve a custom fact"
  create_remote_file(agent, cust_fact_path, cust_fact)
  on(agent, facter("--external-dir=#{facts_dir} --custom-dir=#{facts_dir} test"))
  assert_equal("CUSTOM", stdout.chomp)

  # Adding external fact should give precedence to the EXTERNAL fact
  step "Agent #{agent}: create and resolve an external fact"
  create_remote_file(agent, ext_fact_path, ext_fact)
  on(agent, facter("--external-dir=#{facts_dir} --custom-dir=#{facts_dir} test"))
  assert_equal("EXTERNAL", stdout.chomp)

  # Custom fact with weight > 10000 should give precedence to the CUSTOM fact
  step "Agent #{agent}: resolve a custom fact with weight of 10001"
  create_remote_file(agent, cust_fact_path, cust_fact("has_weight 10001"))
  on(agent, facter("--external-dir=#{facts_dir} --custom-dir=#{facts_dir} test"))
  assert_equal("CUSTOM", stdout.chomp)

  # Custom fact with weight <= 10000 should give precedence to the EXTERNAL fact
  step "Agent #{agent}: resolve a custom fact with weight of 10000"
  create_remote_file(agent, cust_fact_path, cust_fact("has_weight 10000"))
  on(agent, facter("--external-dir=#{facts_dir} --custom-dir=#{facts_dir} test"))
  assert_equal("EXTERNAL", stdout.chomp)

  # Custom fact with a confine should give precedence to the EXTERNAL fact
  # (from FACT-1413)
  step "Agent #{agent}: resolve a custom fact with a confine"
  create_remote_file(agent, cust_fact_path, cust_fact("confine :kernel=>'linux'"))
  on(agent, facter("--external-dir=#{facts_dir} --custom-dir=#{facts_dir} test"))
  assert_equal("EXTERNAL", stdout.chomp)

  teardown do
    on(agent, "rm -rf #{facts_dir}")
  end
end
