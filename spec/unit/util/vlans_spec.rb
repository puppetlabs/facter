#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'facter/util/vlans'

describe Facter::Util::Vlans do
  it "should return a list of vlans on Linux" do
    sample_output_file = File.dirname(__FILE__) + '/../data/linux_vlan_config'
    linux_vlanconfig = File.new(sample_output_file).read();
    Facter::Util::Vlans.stubs(:get_vlan_config).returns(linux_vlanconfig)
    Facter::Util::Vlans.get_vlans().should == %{400,300,200,100}
  end
end
