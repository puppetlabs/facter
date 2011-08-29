#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'facter'
require 'facter/util/ip'

describe "Per Interface IP facts" do
    it "should replace the ':' in an interface list with '_'" do
        # So we look supported
        Facter.fact(:kernel).stubs(:value).returns("SunOS")

        Facter::Util::IP.stubs(:get_interfaces).returns %w{eth0:1 eth1:2}
        Facter.fact(:interfaces).value.should == %{eth0_1,eth1_2}
    end

  it "should replace non-alphanumerics in an interface list with '_'" do
    Facter.fact(:kernel).stubs(:value).returns("windows")

    Facter::Util::IP.stubs(:get_interfaces).returns ["Local Area Connection", "Loopback \"Pseudo-Interface\" (#1)"]
    Facter.fact(:interfaces).value.should == %{Local_Area_Connection,Loopback__Pseudo_Interface____1_}
  end
end
