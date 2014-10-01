#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "rackspace facts" do
  describe "on Rackspace Cloud" do
    before :each do
      Facter.collection.internal_loader.load(:rackspace)
    end

    it "should set is_rsc to true" do
      Facter::Util::Resolution.stubs(:exec).with("/usr/bin/xenstore-read vm-data/provider_data/provider 2> /dev/null").returns("Rackspace")
      Facter.fact(:is_rsc).value.should == "true"
    end

    it "should set the region to dfw" do
      Facter.fact(:is_rsc).stubs(:value).returns("true")
      Facter::Util::Resolution.stubs(:exec).with("/usr/bin/xenstore-read vm-data/provider_data/region 2> /dev/null").returns("dfw")
      Facter.fact(:rsc_region).value.should == "dfw"
    end

    it "should get the instance id" do
      Facter.fact(:is_rsc).stubs(:value).returns("true")
      Facter::Util::Resolution.stubs(:exec).with("/usr/bin/xenstore-read name").returns("instance-75a96685-85d6-44c6-aed8-41ef0fb2cfcc")
      Facter.fact(:rsc_instance_id).value.should == "75a96685-85d6-44c6-aed8-41ef0fb2cfcc"
    end
  end

  describe "not on Rackspace Cloud" do
    before do
      Facter.collection.internal_loader.load(:rackspace)
    end

    it "shouldn't set is_rsc" do
      Facter::Util::Resolution.stubs(:exec).with("/usr/bin/xenstore-read vm-data/provider_data/provider 2> /dev/null").returns("other")
      Facter.fact(:is_rsc).value.should == nil
    end
  end
end
