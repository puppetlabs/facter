test_name "Facter should not display external facts when 'load_external' method is called with false"  do
  tag 'risk:high'

  confine :except, :platform => 'windows'

  require 'facter/acceptance/user_fact_utils'
  require "puppet/acceptance/common_utils"
  extend Facter::Acceptance::UserFactUtils

  script_contents1 = <<-NO_EXTERNAL
  require 'facter'
  Facter.load_external(false)
  output = Facter.to_hash
  exit output["my_external_fact"] == nil
  NO_EXTERNAL

  script_contents2 = <<-WITH_EXTERNAL
  require 'facter'
  output = Facter.to_hash
  exit output["my_external_fact"] == nil
  WITH_EXTERNAL

  agents.each do |agent|
    factsd = get_factsd_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    ext = get_external_fact_script_extension(agent['platform'])
    ext_fact = File.join(factsd, "external_fact#{ext}")

    if agent['platform'] =~ /windows/
      content = <<EOM
echo "my_external_fact=value"
EOM
    else
      content = <<EOM
#!/bin/sh
echo "my_external_fact=value"
EOM
    end

    script_dir = agent.tmpdir('scripts')
    script_name1 = File.join(script_dir, "script_without_ext_facts")
    script_name2 = File.join(script_dir, "script_with_ext_facts")
    create_remote_file(agent, script_name1, script_contents1)
    create_remote_file(agent, script_name2, script_contents2)

    teardown do
      agent.rm_rf(ext_fact)
      agent.rm_rf(script_dir)
    end

    step "Agent #{agent}: create facts.d directory and fact" do
      agent.mkdir_p(factsd)
      create_remote_file(agent, ext_fact, content)
      agent.chmod('+x', ext_fact)
    end

    step "Agent #{agent}: ensure that external fact is loaded and resolved" do
      on(agent, "#{ruby_command(agent)} #{script_name2}", :acceptable_exit_codes => 1)
    end

    step "Agent #{agent}: ensure that external fact is not displayed when load_external method was called with false" do
      on(agent, "#{ruby_command(agent)} #{script_name1}", :acceptable_exit_codes => 0)
    end
  end
end

