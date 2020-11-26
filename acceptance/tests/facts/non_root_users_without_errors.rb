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
    facter_path = agent.which('facter').chomp

    step "Agent #{agent}: create a #{non_root_user} user to run facter with" do
      on(agent, "puppet resource user #{non_root_user} ensure=present shell='#{user_shell(agent)}'")
    end

    teardown do
      on(agent, puppet("resource user #{non_root_user} ensure=absent"))
    end

    step "Agent #{agent}: run facter as #{non_root_user} and get no errors" do
      on(agent, %Q[su #{non_root_user} -c "'#{facter_path}' #{@options[:trace]}"]) do |facter_results|
        assert_empty(facter_results.stderr.chomp, "Expected no errors from facter when run as user #{non_root_user}")
      end
    end
  end
end
