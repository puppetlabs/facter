test_name "--debug command-line option prints debugging information to stderr"

#
# This test is intended to ensure that the --debug command-line option works
# properly. This option prints debugging information to stderr.
#

agents.each do |agent|
  step "Agent #{agent}: retrieve debug info from stderr using --debug option"
  on(agent, "cfacter --debug") do
    assert_match(/DEBUG/, stderr, "Expected DEBUG information in stderr")
  end
end
