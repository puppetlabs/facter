test_name "--parallel argument does not generate any errors" do
  tag 'risk:high'

  agents.each do |agent|
    step "--parallel should generate no errors" do
      on(agent, facter("--parallel --debug"), :acceptable_exit_codes => 0) do |facter_output|
        assert_match(/Resolving fact in parallel/, facter_output.stderr, "Resolving facts in parallel")
      end
    end
  end
end
