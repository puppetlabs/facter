#! /usr/bin/env ruby

require 'spec_helper'

describe "on Solaris" do
  before do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    zone_list = <<-EOF
0:global:running:/::native:shared
-:local:configured:/::native:shared
-:zoneA:stopped:/::native:shared
    EOF
    Facter::Core::Execution.stubs(:execute).with('/usr/sbin/zoneadm list -cp', {:on_fail => nil}).returns(zone_list)
    Facter.collection.internal_loader.load(:zones)
  end

  describe "number of zones" do
    it "should output number of zones" do
      Facter.fact(:zones).value.should == 3
    end
  end

  describe "zone specific values" do
    it "Fact#zone_<z>_status" do
      {'global' => 'running', 'local' => 'configured', 'zoneA' => 'stopped'}.each do |key, val|
        Facter.value("zone_%s_status" % key).should == val
      end
    end

    it "Fact#zone_<z>_id" do
      {'global' => '0', 'local' => '-', 'zoneA' => '-'}.each do |key, val|
        Facter.value("zone_%s_id" % key).should == val
      end
    end

    it "Fact#zone_<z>_path" do
      {'global' => '/', 'local' => '/', 'zoneA' => '/'}.each do |key, val|
        Facter.value("zone_%s_path" % key).should == val
      end
    end

    it "Fact#zone_<z>_brand" do
      {'global' => 'native', 'local' => 'native', 'zoneA' => 'native'}.each do |key, val|
        Facter.value("zone_%s_brand" % key).should == val
      end
    end

    it "Fact#zone_<z>_iptype" do
      {'global' => 'shared', 'local' => 'shared', 'zoneA' => 'shared'}.each do |key, val|
        Facter.value("zone_%s_iptype" % key).should == val
      end
    end
  end
end

