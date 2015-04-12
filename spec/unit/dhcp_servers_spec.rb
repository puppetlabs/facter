require 'spec_helper'

describe "DHCP server facts" do
  describe "on Linux OS's" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns 'Linux'
      Facter::Util::FileRead.stubs(:read).with('/proc/net/route').returns(my_fixture_read('route'))
    end

    describe "with nmcli version <= 0.9.8 available" do
      before :each do
        Facter::Core::Execution.stubs(:which).with('nmcli').returns('/usr/bin/nmcli')
        Facter::Core::Execution.stubs(:exec).with('nmcli --version').returns('nmcli tool, version 0.9.8.0')
      end

      describe "with a main interface configured with DHCP" do
        before :each do
          Facter::Core::Execution.stubs(:exec).with("nmcli d").returns(my_fixture_read("nmcli_devices"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d list iface eth0").returns(my_fixture_read("nmcli_eth0_dhcp"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d list iface wlan0").returns(my_fixture_read("nmcli_wlan0_dhcp"))
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE nm 2>/dev/null').returns("connected\n")
        end

        it "should produce a dhcp_servers fact that includes values for 'system' as well as each dhcp enabled interface" do
          Facter.fact(:dhcp_servers).value.should == { 'system' => '192.168.1.1', 'eth0' => '192.168.1.1', 'wlan0' => '192.168.2.1' }
        end
      end

      describe "with a main interface NOT configured with DHCP" do
        before :each do
          Facter::Core::Execution.stubs(:exec).with("nmcli d").returns(my_fixture_read("nmcli_devices"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d list iface eth0").returns(my_fixture_read("nmcli_eth0_static"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d list iface wlan0").returns(my_fixture_read("nmcli_wlan0_dhcp"))
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE nm 2>/dev/null').returns("connected\n")
        end

        it "should a dhcp_servers fact that includes values for each dhcp enables interface and NO 'system' value" do
          Facter.fact(:dhcp_servers).value.should == {'wlan0' => '192.168.2.1' }
        end
      end

      describe "with no default gateway" do
        before :each do
          Facter::Util::FileRead.stubs(:read).with('/proc/net/route').returns(my_fixture_read('route_nogw'))
          Facter::Core::Execution.stubs(:exec).with("nmcli d").returns(my_fixture_read("nmcli_devices"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d list iface eth0").returns(my_fixture_read("nmcli_eth0_dhcp"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d list iface wlan0").returns(my_fixture_read("nmcli_wlan0_dhcp"))
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE nm 2>/dev/null').returns("connected\n")
        end

        it "should a dhcp_servers fact that includes values for each dhcp enables interface and NO 'system' value" do
          Facter.fact(:dhcp_servers).value.should == {'eth0' => '192.168.1.1', 'wlan0' => '192.168.2.1' }
        end
      end

      describe "with no DHCP enabled interfaces" do
        before :each do
          Facter::Core::Execution.stubs(:exec).with("nmcli d").returns(my_fixture_read("nmcli_devices"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d list iface eth0").returns(my_fixture_read("nmcli_eth0_static"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d list iface wlan0").returns(my_fixture_read("nmcli_wlan0_static"))
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE nm 2>/dev/null').returns("connected\n")
        end

        it "should not produce a dhcp_servers fact" do
          Facter.fact(:dhcp_servers).value.should be_nil
        end
      end

      describe "with no CONNECTED devices" do
        before :each do
          Facter::Core::Execution.stubs(:exec).with("nmcli d").returns(my_fixture_read("nmcli_devices_disconnected"))
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE nm 2>/dev/null').returns("disconnected\n")
        end

        it "should not produce a dhcp_servers fact" do
          Facter.fact(:dhcp_servers).value.should be_nil
        end
      end
    end

    describe "with nmcli version >= 0.9.9 available" do
      before :each do
        Facter::Core::Execution.stubs(:which).with('nmcli').returns('/usr/bin/nmcli')
        Facter::Core::Execution.stubs(:exec).with('nmcli --version').returns('nmcli tool, version 0.9.9.0-20.git20131003.fc20')
      end

      describe "with a main interface configured with DHCP" do
        before :each do
          Facter::Core::Execution.stubs(:exec).with("nmcli d").returns(my_fixture_read("nmcli_devices"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d show eth0").returns(my_fixture_read("nmcli_eth0_dhcp"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d show wlan0").returns(my_fixture_read("nmcli_wlan0_dhcp"))
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE g 2>/dev/null').returns("connected\n")
        end

        it "should produce a dhcp_servers fact that includes values for 'system' as well as each dhcp enabled interface" do
          Facter.fact(:dhcp_servers).value.should == { 'system' => '192.168.1.1', 'eth0' => '192.168.1.1', 'wlan0' => '192.168.2.1' }
        end
      end

      describe "with a main interface NOT configured with DHCP" do
        before :each do
          Facter::Core::Execution.stubs(:exec).with("nmcli d").returns(my_fixture_read("nmcli_devices"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d show eth0").returns(my_fixture_read("nmcli_eth0_static"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d show wlan0").returns(my_fixture_read("nmcli_wlan0_dhcp"))
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE g 2>/dev/null').returns("connected\n")
        end

        it "should a dhcp_servers fact that includes values for each dhcp enables interface and NO 'system' value" do
          Facter.fact(:dhcp_servers).value.should == {'wlan0' => '192.168.2.1' }
        end
      end

      describe "with no default gateway" do
        before :each do
          Facter::Util::FileRead.stubs(:read).with('/proc/net/route').returns(my_fixture_read('route_nogw'))
          Facter::Core::Execution.stubs(:exec).with("nmcli d").returns(my_fixture_read("nmcli_devices"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d show eth0").returns(my_fixture_read("nmcli_eth0_dhcp"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d show wlan0").returns(my_fixture_read("nmcli_wlan0_dhcp"))
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE g 2>/dev/null').returns("connected\n")
        end

        it "should a dhcp_servers fact that includes values for each dhcp enables interface and NO 'system' value" do
          Facter.fact(:dhcp_servers).value.should == {'eth0' => '192.168.1.1', 'wlan0' => '192.168.2.1' }
        end
      end

      describe "with no DHCP enabled interfaces" do
        before :each do
          Facter::Core::Execution.stubs(:exec).with("nmcli d").returns(my_fixture_read("nmcli_devices"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d show eth0").returns(my_fixture_read("nmcli_eth0_static"))
          Facter::Core::Execution.stubs(:exec).with("nmcli -f all d show wlan0").returns(my_fixture_read("nmcli_wlan0_static"))
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE g 2>/dev/null').returns("connected\n")
        end

        it "should not produce a dhcp_servers fact" do
          Facter.fact(:dhcp_servers).value.should be_nil
        end
      end

      describe "with no CONNECTED devices" do
        before :each do
          Facter::Core::Execution.stubs(:exec).with("nmcli d").returns(my_fixture_read("nmcli_devices_disconnected"))
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE g 2>/dev/null').returns("disconnected\n")
        end

        it "should not produce a dhcp_servers fact" do
          Facter.fact(:dhcp_servers).value.should be_nil
        end
      end
    end

    describe 'without NetworkManager running' do
      before :each do
        Facter::Core::Execution.stubs(:which).with('nmcli').returns('/usr/bin/nmcli')
      end

      describe 'with nmcli version >= 0.9.9 available' do
        before :each do
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE g 2>/dev/null').returns("unknown\n")
          Facter::Core::Execution.stubs(:exec).with('nmcli --version').returns('nmcli tool, version 0.9.9.0')
        end

        it 'should not produce a dhcp_servers fact' do
          Facter.fact(:dhcp_servers).value.should be_nil
        end
      end

      describe 'with nmcli version <= 0.9.8 available' do
        before :each do
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE nm 2>/dev/null').returns("unknown\n")
          Facter::Core::Execution.stubs(:exec).with('nmcli --version').returns('nmcli tool, version 0.9.7.0')
        end

        it 'should not produce a dhcp_servers fact' do
          Facter.fact(:dhcp_servers).value.should be_nil
        end
      end
      describe 'with nmcli version >= 0.9.9 available but printing an error to STDERR' do
        before :each do
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE g 2>/dev/null').returns("\n")
          Facter::Core::Execution.stubs(:exec).with('nmcli --version').returns('nmcli tool, version 0.9.9.0')
        end

        it 'should not produce a dhcp_servers fact' do
          Facter.fact(:dhcp_servers).value.should be_nil
        end
      end

      describe 'with nmcli version <= 0.9.8 available but printing an error to STDERR' do
        before :each do
          Facter::Core::Execution.stubs(:exec).with('nmcli -t -f STATE nm 2>/dev/null').returns("\n")
          Facter::Core::Execution.stubs(:exec).with('nmcli --version').returns('nmcli tool, version 0.9.7.0')
        end

        it 'should not produce a dhcp_servers fact' do
          Facter.fact(:dhcp_servers).value.should be_nil
        end
      end

    end

    describe "without nmcli available" do
      before :each do
        Facter::Core::Execution.stubs(:which).with('nmcli').returns(nil)
      end

      it "should not produce a dhcp_server fact" do
        Facter.fact(:dhcp_servers).value.should be_nil
      end
    end
  end
end
