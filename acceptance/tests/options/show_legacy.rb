test_name "--show-legacy command-line option results in output with legacy (hidden) facts"

agents.each do |agent|
  step "Agent #{agent}: retrieve legacy output using a hash"
  on(agent, facter("--show-legacy")) do
    assert_match(/^rubyversion => [0-9]+\.[0-9]+\.[0-9]+$/, stdout.chomp, 'hash legacy output does not contain legacy fact rubyversion')
  end

  step "Agent #{agent}: retrieve legacy output using the --json option"
  on(agent, facter("--show-legacy --json")) do
    assert_match(/^  "rubyversion": "[0-9]+\.[0-9]+\.[0-9]+",$/, stdout.chomp, 'json legacy output does not contain legacy fact rubyversion')
  end
end
