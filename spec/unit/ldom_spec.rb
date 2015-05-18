#!/usr/bin/env ruby

require 'spec_helper'

def ldom_fixtures(filename)
  File.read(fixtures('ldom', filename))
end

describe "ldom fact" do
  before do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
  end

  describe "when running on ldom hardware" do
    before :each do
      # For virtinfo documentation:
      # http://docs.oracle.com/cd/E23824_01/html/821-1462/virtinfo-1m.html
      Facter.fact(:hardwareisa).stubs(:value).returns("sparc")
      Facter::Core::Execution.stubs(:which).with("virtinfo").returns 'virtinfo'
      Facter::Core::Execution.stubs(:exec).with("virtinfo -ap").
        returns(ldom_fixtures('ldom_v1'))
      Facter.collection.internal_loader.load(:ldom)
    end

    it "should return correct impl on version 1.0" do
      Facter.fact(:ldom_domainrole_impl).value.should == "LDoms"
    end

    it "should return correct control on version 1.0" do
      Facter.fact(:ldom_domainrole_control).value.should == "false"
    end

    it "should return correct io on version 1.0" do
      Facter.fact(:ldom_domainrole_io).value.should == "true"
    end

    it "should return correct service on version 1.0" do
      Facter.fact(:ldom_domainrole_service).value.should == "true"
    end

    it "should return correct root on version 1.0" do
      Facter.fact(:ldom_domainrole_root).value.should == "true"
    end

    it "should return correct domain name on version 1.0" do
      Facter.fact(:ldom_domainname).value.should == "primary"
    end

    it "should return correct uuid on version 1.0" do
      Facter.fact(:ldom_domainuuid).value.should == "8e0d6ec5-cd55-e57f-ae9f-b4cc050999a4"
    end

    it "should return correct ldomcontrol on version 1.0" do
      Facter.fact(:ldom_domaincontrol).value.should == "san-t2k-6"
    end

    it "should return correct serial on version 1.0" do
      Facter.fact(:ldom_domainchassis).value.should == "0704RB0280"
    end
  end

  describe "when running on non ldom hardware" do
    before :each do
      Facter.fact(:hardwareisa).stubs(:value).returns("sparc")
      Facter::Core::Execution.stubs(:which).with("virtinfo").returns(nil)
      Facter.collection.internal_loader.load(:ldom)
    end

    it "should return correct virtual" do
      Facter.fact(:ldom_domainrole_impl).should == nil
    end
  end

  describe "when running on non-sparc hardware" do
    before :each do
      Facter.fact(:hardwareisa).stubs(:value).returns("i386")
      Facter::Core::Execution.stubs(:which).with("virtinfo").returns 'virtinfo'
    end

    it "should not try to resolve the ldom facts" do
      Facter.fact(:ldom_domainrole_impl).should == nil
    end
  end
end
