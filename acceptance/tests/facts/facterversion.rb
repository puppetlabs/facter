test_name "C15286: verify facterversion fact" do
  tag 'risk:high'

  agents.each do |agent|
    step("verify that fact facterversion is a version string") do
      on(agent, facter("facterversion")) do |facter_result|
        assert_match(/\d+\.\d+\.\d+/, facter_result.stdout.chomp, "Expected 'facterversion' fact to be a version string")
      end
    end
  end
end
