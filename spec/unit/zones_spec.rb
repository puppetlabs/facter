#!usr/bin/env rspec

require 'spec_helper'
require 'facter'

describe "on Solaris" do
  before do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter.fact(:kernelrelease).stubs(:value).returns("5.10")
  end

  describe "number of zones" do
    it "should output number of zones" do
      zone_list = File.open(fixtures('zones', 'zoneadm_list.out')).readlines
      Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/zoneadm list -cp 2>/dev/null').returns(zone_list)
      Facter.fact(:zones).value.should == zone_list.size
    end
  end

  describe "when zoneadm returns error" do
    it "should not populate the zones fact" do
      Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/zoneadm list -cp 2>/dev/null').returns(nil)
      Facter.fact(:zones).value.should be_nil
    end
  end

  describe "per zone fact and its status" do
    it "should have a per zone fact with its status" do
      zone_list = File.open(fixtures('zones', 'zoneadm_list.out')).readlines
      zone_list.each do |this_line|
        this_zone = this_line.split(":")[1]
        this_zone_stat = this_line.split(":")[2]
        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/zoneadm list -cp 2>/dev/null').returns(zone_list)
        Facter.collection.loader.load(:zones)
        Facter.value("zone_#{this_zone}_status".to_sym).should == this_zone_stat
      end
    end
  end
end
