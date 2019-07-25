test_name '(FACT-1964) Facter mountpoints does not show rootfs as type for root directory' do

  confine :to, :platform => /el/

  agents.each do |agent|
    step 'Ensure that mountpoints does not contain rootfs as type for root directory' do
      on(agent, facter("mountpoints")) do |facter_result|
        assert_no_match(/rootfs/, facter_result.stdout.chomp, "Expected mountpoint with rootfs type to not be present")
      end
    end
  end
end
