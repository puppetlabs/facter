#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'facter'

describe "OS Major Release fact" do
  ['Amazon','CentOS','CloudLinux','Debian','Fedora','OEL','OracleLinux','OVS','RedHat','Scientific','SLC','CumulusLinux'].each do |operatingsystem|
    context "on #{operatingsystem} operatingsystems" do
      it "should be derived from operatingsystemrelease" do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        Facter.fact(:operatingsystem).stubs(:value).returns(operatingsystem)
        Facter.fact(:operatingsystemrelease).stubs(:value).returns("6.3")
        Facter.fact(:operatingsystemmajrelease).value.should == "6"
      end
    end
  end

  context "on Solaris operatingsystems" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
      Facter.fact(:operatingsystem).stubs(:value).returns("Solaris")
    end

    it "should correctly derive from operatingsystemrelease on solaris 10" do
      Facter.fact(:operatingsystemrelease).expects(:value).returns("10_u8")
      Facter.fact(:operatingsystemmajrelease).value.should == "10"
    end

    it "should correctly derive from operatingsystemrelease on solaris 11 (old version scheme)" do
      Facter.fact(:operatingsystemrelease).expects(:value).returns("11 11/11")
      Facter.fact(:operatingsystemmajrelease).value.should == "11"
    end

    it "should correctly derive from operatingsystemrelease on solaris 11 (new version scheme)" do
      Facter.fact(:operatingsystemrelease).expects(:value).returns("11.1")
      Facter.fact(:operatingsystemmajrelease).value.should == "11"
    end
  end
end
