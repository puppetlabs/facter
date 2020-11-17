test_name "C14892: external facts should only be run once" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    factsd = get_factsd_dir(agent['platform'],
                            on(agent, facter("kernelmajversion #{@options[:trace]}")).stdout.chomp.to_f)
    ext = get_external_fact_script_extension(agent['platform'])
    ext_fact = File.join(factsd, "external_fact#{ext}")

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

    teardown do
      agent.rm_rf(ext_fact)
    end

    step "Agent #{agent}: create facts.d directory and fact" do
      agent.mkdir_p(factsd)
      create_remote_file(agent, ext_fact, content)
      agent.chmod('+x', ext_fact)
    end

    step "Agent #{agent}: ensure the fact is only executed once" do
      on(agent, facter((@options[:trace]).to_s)) do |facter_output|
        lines = facter_output.stderr.split('\n')
        times = lines.count { |line| line =~ /SCRIPT CALLED/ }
        assert_equal(1, times, "External fact should only execute once: #{facter_output.stderr}")
      end
    end
  end
end
