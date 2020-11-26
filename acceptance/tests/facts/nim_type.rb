test_name "Test nim_type fact" do

  confine :to, :platform => /aix/

  agents.each do |agent|
    step("verify that nim_type is retrieved correctly") do
      on(agent, facter("nim_type #{@options[:trace]}")) do |facter_result|
        assert_equal("standalone", facter_result.stdout.chomp)
      end
    end
  end
end
