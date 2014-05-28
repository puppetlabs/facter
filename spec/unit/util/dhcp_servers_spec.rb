#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/dhcp_servers'

describe Facter::Util::DHCPServers do
  describe "nmcli_version" do
    {
      'nmcli tool, version 0.9.8.0' => 980,
      'nmcli tool, version 0.9.8.9' => 989,
      'nmcli tool, version 0.9.9.0' => 990,
      'nmcli tool, version 0.9.9.9' => 999,
      'version 0.9.9.0-20.git20131003.fc20' => 990,
    }.each do |version, expected|
      it "should turn #{version} into the integer #{expected}" do
        Facter::Core::Execution.stubs(:which).with('nmcli').returns('/usr/bin/nmcli')
        Facter::Core::Execution.stubs(:exec).with('nmcli --version').returns(version)
        
        result = Facter::Util::DHCPServers.nmcli_version
        result.is_a?(Integer).should be true
        result.should == expected
      end
    end
  end
end


