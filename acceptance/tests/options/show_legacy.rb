# This test is intended to demonstrate that the `--show-legacy` command line option
# causes hidden old facts to appear in the fact list.
test_name "C87580: --show-legacy command-line option results in output with legacy (hidden) facts" do

  agents.each do |agent|
    step "Agent #{agent}: retrieve legacy output using a hash" do
      on(agent, facter("--show-legacy")) do
        assert_match(/^rubyversion => [0-9]+\.[0-9]+\.[0-9]+$/, stdout.chomp, 'hash legacy output does not contain legacy fact rubyversion')
      end
    end

    step "Agent #{agent}: retrieve legacy output using the --json option" do
      on(agent, facter("--show-legacy --json")) do
        assert_match(/^  "rubyversion": "[0-9]+\.[0-9]+\.[0-9]+",$/, stdout.chomp, 'json legacy output does not contain legacy fact rubyversion')
      end
    end
  end
end
