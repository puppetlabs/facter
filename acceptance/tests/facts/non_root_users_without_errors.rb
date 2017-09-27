test_name "C59196: running facter as a non-root user should not produce permission errors" do
  tag 'risk:high'

  confine :except, :platform => 'windows' # this test currently only supported on unix systems FACT-1647
  confine :except, :platform => 'aix' # system su(1) command prints errors cannot access parent directories and ticket FACT-1586
  confine :except, :platform => 'cisco' # system su(1) command prints errors cannot access parent directories
  confine :except, :platform => 'osx' # system su(1) command prints errors cannot access parent directories
  confine :except, :platform => 'solaris' # system su(1) command prints errors cannot access parent directories
  confine :except, :platform => 'eos-' # does not support user creation ARISTA-37

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    non_root_user = "nonroot"
    facter_path = on(agent, "which facter").stdout.chomp

    step "Agent #{agent}: create a #{non_root_user} user to run facter with" do
      on(agent, "puppet resource user #{non_root_user} ensure=present shell='#{user_shell(agent)}'")
    end

    teardown do
      on(agent, puppet("resource user #{non_root_user} ensure=absent"))
    end

    step "Agent #{agent}: run facter as #{non_root_user} and get no errors" do
      on(agent, %Q[su #{non_root_user} -c "'#{facter_path}'"]) do |facter_results|
        # NOTE: stderr should be empty here. The other case for power linux machines is
        # necessary until FACT-1765 is resolved.
        if power_linux?(agent)
          assert_match(/dmidecode not found at configured location/, facter_results.stderr.chomp, 'Facter should have written a warning regarding a missing dmidecode component')
        else
          assert_empty(facter_results.stderr.chomp, 'Facter should not have written to stderr')
        end
      end
    end
  end
end
