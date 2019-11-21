test_name "Test facter os reports correct os.windows.system32" do

  confine :to, :platform => /windows/

  step "Install Windows remote desktop feature" do
    on(agent, powershell("facter os.windows.system32")) do |facter_before_output|
      assert_equal("C:\\Windows\\system32", facter_before_output.stdout.chomp, 'Before windows feature installation, should be C:\\Windows\\system32')
    end
    on(agent, powershell("Add-WindowsFeature –Name RDS-RD-Server –IncludeAllSubFeature"))
    on(agent, powershell("'Import-module servermanager ; (Get-WindowsFeature -name RDS-RD-Server).Installed'")) do |installed_feature|
      assert_equal("True", installed_feature.stdout.chomp, 'Result should be true for installed RDS-RD-Server feature')
    end
    agent.reboot
  end

  step "Verify facter os reports correct system32 variable" do
    on(agent, powershell("facter os.windows.system32")) do |facter_output|
      assert_equal("C:\\Windows\\system32", facter_output.stdout.chomp, 'Result should be C:\\Windows\\system32')
    end
  end
end
