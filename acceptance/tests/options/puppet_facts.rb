# Verify that -p loads external and custom facts from puppet locations
test_name "C14783: facter -p loads facts from puppet" do
  tag 'risk:high'

  confine :to, :platform => /Skipped/

  agents.each do |agent|
    external_dir = agent.puppet['pluginfactdest']
    external_file = File.join(external_dir, "external.txt")
    custom_dir = File.join(agent.puppet['plugindest'], "facter")
    custom_file = File.join(custom_dir, 'custom.rb')

    teardown do
      agent.rm_rf(external_file)
      agent.rm_rf(custom_dir)
    end

    step "Agent #{agent}: create external fact" do
      agent.mkdir_p(external_dir)
      create_remote_file(agent, external_file, "external=external")
    end

    step "Agent #{agent}: create custom fact" do
      agent.mkdir_p(custom_dir)
      create_remote_file(agent, custom_file, "Facter.add(:custom) { setcode { 'custom' } }")
    end

    step "Agent #{agent}: verify facts" do
      on(agent, facter("-p external #{@options[:trace]}")) do |facter_output|
        assert_equal("external", facter_output.stdout.chomp)
      end

      on(agent, facter("-p custom #{@options[:trace]}")) do |facter_output|
        assert_equal("custom", facter_output.stdout.chomp)
      end
    end
  end
end
