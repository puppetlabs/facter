#!usr/bin/env rspec

require 'spec_helper'

describe "on Solaris" do
  before do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter.fact(:kernelrelease).stubs(:value).returns("5.10")
  end

  describe "number of zones" do
    it "should output number of zones" do
      zone_list = my_fixture_read("zoneadm-list.out")
      Facter::Util::Resolution.stubs(:exec).
        with('/usr/sbin/zoneadm list -cp 2>/dev/null').
        returns(zone_list)
      Facter.fact(:zones).value.should == 3
    end
  end

  describe "per zone fact and its status" do
    it "should have a per zone fact with its status" do
      zone_list = my_fixture_read("zoneadm-list.out")
      Facter::Util::Resolution.stubs(:exec).
        with('/usr/sbin/zoneadm list -cp 2>/dev/null').
        returns(zone_list)

      Facter.collection.loader.load(:zones)
      Facter.value("zone_global_status").should == "running"
      Facter.value("zone_local_status").should  == "configured"
      Facter.value("zone_zoneA_status").should  == "stopped"
    end
  end
end