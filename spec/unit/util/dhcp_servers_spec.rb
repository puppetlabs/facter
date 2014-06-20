#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/dhcp_servers'

describe Facter::Util::DHCPServers do

  describe "retrieving the gateway device" do
    it "returns nil when there are no default routes" do
      Facter::Util::FileRead.stubs(:read).with('/proc/net/route').returns(my_fixture_read('route_nogw'))
      described_class.gateway_device.should be_nil
    end

    it "returns the interface associated with the first default route" do
      Facter::Util::FileRead.stubs(:read).with('/proc/net/route').returns(my_fixture_read('route'))
      described_class.gateway_device.should eq "eth0"
    end
  end

  describe "nmcli_version" do
    {
      'nmcli tool, version 0.9.8.0' => [0, 9, 8, 0],
      'nmcli tool, version 0.9.8.10' => [0, 9, 8, 10],
      'nmcli tool, version 0.9.8.9' => [0, 9, 8, 9],
      'nmcli tool, version 0.9.9.0' => [0, 9, 9, 0],
      'nmcli tool, version 0.9.9.9' => [0, 9, 9, 9],
      'version 0.9.9.0-20.git20131003.fc20' => [0, 9, 9, 0],
      'nmcli tool, version 0.9.9' => [0, 9, 9, 0],
      'nmcli tool, version 0.9' => [0, 9, 0, 0],
      'nmcli tool, version 1' => [1, 0, 0, 0]
    }.each do |version, expected|
      it "should turn #{version} into the integer #{expected}" do
        Facter::Core::Execution.stubs(:which).with('nmcli').returns('/usr/bin/nmcli')
        Facter::Core::Execution.stubs(:exec).with('nmcli --version').returns(version)
        
        result = Facter::Util::DHCPServers.nmcli_version
        result.is_a?(Array).should be true
        result.should == expected
      end
    end
  end

  describe "device_dhcp_server" do
    {
        '0.1.2.3' => false,
        '0.9.8.10' => false,
        '0.9.9.0' => true,
        '0.9.10.0' => true,
        '0.10.0.0' => true,
        '1.0.0.0' => true
    }.each do |version, uses_show|
      it "should use #{if uses_show then 'show' else 'list' end} for version #{version}" do
        command = if uses_show then 'nmcli -f all d show eth0' else 'nmcli -f all d list iface eth0' end
        Facter::Core::Execution.stubs(:which).with('nmcli').returns('/usr/bin/nmcli')
        Facter::Core::Execution.stubs(:exec).with('nmcli --version').returns "nmcli tool, version #{version}"
        Facter::Core::Execution.stubs(:exec).with(command).returns 'DHCP4.OPTION[1]: dhcp_server_identifier = 192.168.1.1'
        Facter::Util::DHCPServers.device_dhcp_server('eth0').should == '192.168.1.1'
      end
    end
  end
end


