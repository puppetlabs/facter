test_name "Facter should not write to STDERR if all is well"

step "Run facter on the agent"
on agents, facter do
  assert_equal("", stderr, "Facter is writing to STDERR, that's not good.")
end
