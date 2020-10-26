test_name "--sequential argument does not generate any errors" do
  tag 'risk:high'

  agents.each do |agent|
    step "--sequential should generate no errors" do
      on(agent, facter("--sequential --debug"), :acceptable_exit_codes => 0) do |facter_output|
        assert_match(/Resolving facts sequentially/, facter_output.stderr, "Resolving facts sequentially")
      end
    end
  end
end
