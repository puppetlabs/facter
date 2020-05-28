test_name "C64315: external facts that print messages to stderr should be seen on stderr" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    factsd = get_factsd_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
    ext = get_external_fact_script_extension(agent['platform'])
    ext_fact = File.join(factsd, "external_fact#{ext}")

    if agent['platform'] =~ /windows/
      content = <<EOM
@ECHO OFF

echo "SCRIPT STDERR" >&2
echo "test=value"
EOM
    else
      content = <<EOM
#!/bin/sh
echo "SCRIPT STDERR" >&2
echo "test=value"
EOM
    end

    teardown do
      on(agent, "rm -f '#{ext_fact}'")
    end

    step "Agent #{agent}: create facts.d directory and fact" do
      on(agent, "mkdir -p '#{factsd}'")
      create_remote_file(agent, ext_fact, content)
      on(agent, "chmod +x '#{ext_fact}'")
    end

    step "Agent #{agent}: external fact stderr messages should appear on stderr from facter" do
      on(agent, facter) do |facter_output|
        assert_match(/WARN.*SCRIPT STDERR/, facter_output.stderr,
                     "Expected facter to output a warning message with the stderr string from the external fact")
      end
    end

    step "Agent #{agent}: external fact stderr messages should appear on stderr from puppet facts" do
      on(agent, puppet("facts")) do |puppet_output|
        assert_match(/Warning.*SCRIPT STDERR/, puppet_output.stderr,
                     "Expected puppet facts to output a warning message with the stderr string from the external fact")
      end
    end
  end
end