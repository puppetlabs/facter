#!usr/bin/env ruby
#Test for zones and zone_[name] facts
#
#Author: Shubhra Sinha Varma
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'facter'

 describe "on Solaris" do
   before do
     Facter.fact(:kernel).stubs(:value).returns("SunOS")
     Facter.fact(:kernelrelease).stubs(:value).returns("5.10")

  end

  describe "number of zones" do
    it "should output number of zones" do
     sample_output_file = File.dirname(__FILE__) + '/data/zones'
     zone_list = File.readlines(sample_output_file)
     Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/zoneadm list -cp 2>/dev/null').returns(zone_list)
     Facter.fact(:zones).value.should == zone_list.size
    end
  end

  describe "per zone fact and its status" do
   it "should have a per zone fact with its status" do
     sample_output_file = File.dirname(__FILE__) + '/data/zones'
     zone_list = File.readlines(sample_output_file)
     zone_list.each do |this_line|
        this_zone = this_line.split(":")[1]
         puts "tz=" + this_zone
        this_zone_stat = this_line.split(":")[2]
         puts "tzs=" + this_zone_stat
        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/zoneadm list -cp 2>/dev/null').returns(zone_list)
        Facter.collection.loader.load(:zones)
        Facter.value("zone_#{this_zone}".to_sym).should == this_zone_stat
      end
    end
  end
end
