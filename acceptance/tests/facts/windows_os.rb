test_name "Test facter os reports correct os.windows.system32" do

#  disable this test until changes in beaker 
#  https://tickets.puppetlabs.com/browse/BKR-1627
#  will allow this test to run in timely manner
  confine :to, :platform => /no-platform/
#  confine :to, :platform => /windows/
#  confine :except, :platform => /2008/

  agents.each do |agent|
    os_type = on(agent, powershell("facter os.windows.installation_type")).stdout.chomp
    domain_firewall_state = on(agent, powershell("'(Get-NetFirewallProfile -Profile Domain).Enabled'")).stdout.chomp
    public_firewall_state = on(agent, powershell("'(Get-NetFirewallProfile -Profile Public).Enabled'")).stdout.chomp
    private_firewall_state = on(agent, powershell("'(Get-NetFirewallProfile -Profile Private).Enabled'")).stdout.chomp
    on(agent, powershell("'Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False'"))

    teardown do
      if os_type == "Server" && on(agent, powershell("'Import-module servermanager ; (Get-WindowsFeature -name RDS-RD-Server).Installed'")).stdout.chomp == "True"
        on(agent, powershell("'Import-module servermanager ; Remove-WindowsFeature –Name RDS-RD-Server'"))
        agent.reboot
        begin
          agent.down?
        rescue
          #TODO: Handle restart pending
          puts 'Assuming that restart was not caught'
        end
        agent.wait_for_port(3389)
        agent.wait_for_port(22)
        on(agent, powershell("Set-NetFirewallProfile -Profile Domain -Enabled #{domain_firewall_state}"))
        on(agent, powershell("Set-NetFirewallProfile -Profile Public -Enabled #{public_firewall_state}"))
        on(agent, powershell("Set-NetFirewallProfile -Profile Private -Enabled #{private_firewall_state}"))
      end
    end

    step "Install Windows remote desktop feature" do
      if os_type == "Server"
        on(agent, powershell("facter os.windows.system32")) do |facter_before_output|
          assert_equal("C:\\Windows\\system32", facter_before_output.stdout.chomp, 'Before windows feature installation, should be C:\\Windows\\system32')
        end
        on(agent, powershell("Add-WindowsFeature –Name RDS-RD-Server –IncludeAllSubFeature"))
        on(agent, powershell("'Import-module servermanager ; (Get-WindowsFeature -name RDS-RD-Server).Installed'")) do |installed_feature|
          assert_equal("True", installed_feature.stdout.chomp, 'Result should be true for installed RDS-RD-Server feature')
        end
        agent.reboot
        #assert_equal(true, agent.down?, 'Cound install RDS-RD-Server, failed to bring the host down')
        begin
          agent.down?
        rescue
          #TODO: Handle restart pending
          puts 'Assuming that restart was not caught'
        end
        agent.wait_for_port(3389)
        agent.wait_for_port(22)
      end
    end

    step "Verify facter os reports correct system32 variable" do
      on(agent, powershell("facter os.windows.system32")) do |facter_output|
        assert_equal("C:\\Windows\\system32", facter_output.stdout.chomp, 'Result should be C:\\Windows\\system32')
      end
    end

  end
end
