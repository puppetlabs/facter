#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/util/vlans'

describe Facter::Util::Vlans do
  it "should return a list of vlans on Linux" do
    linux_vlanconfig = my_fixture_read("linux_vlan_config")
    Facter::Util::Vlans.stubs(:get_vlan_config).returns(linux_vlanconfig)
    Facter::Util::Vlans.get_vlans().should == %{400,300,200,100}
  end
end
