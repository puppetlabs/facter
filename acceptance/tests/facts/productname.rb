test_name "C89604: verify productname fact" do
  tag 'risk:high'

  confine :except, :platform => 'aix' # not supported on
  confine :except, :platform => 'huawei' # not supported on
  confine :except, :platform => 'ppc64' # not supported on linux on powerpc

  agents.each do |agent|
    step("verify the fact productname") do
      on(agent, facter("productname #{@options[:trace]}")) do |facter_result|
        assert_match(/\w+/, facter_result.stdout.chomp, "Expected fact 'productname' to be set")
      end
    end
  end
end
