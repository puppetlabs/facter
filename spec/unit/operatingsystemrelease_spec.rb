#!/usr/bin/env rspec

require 'spec_helper'

describe "Operating System Release fact" do

  before do
    Facter.clear
  end

  after do
    Facter.clear
  end

  test_cases = {
    "CentOS"    => "/etc/redhat-release",
    "RedHat"    => "/etc/redhat-release",
    "Scientific"  => "/etc/redhat-release",
    "Fedora"    => "/etc/fedora-release",
    "MeeGo"     => "/etc/meego-release",
    "OEL"     => "/etc/enterprise-release",
    "oel"     => "/etc/enterprise-release",
    "OVS"     => "/etc/ovs-release",
    "ovs"     => "/etc/ovs-release",
    "OracleLinux" => "/etc/oracle-release",
    "Ascendos"    => "/etc/redhat-release",
  }

  test_cases.each do |system, file|
    describe "with operatingsystem reported as #{system.inspect}" do
      it "should read the #{file.inspect} file" do
        Facter.fact(:operatingsystem).stubs(:value).returns(system)

        File.expects(:open).with(file, "r").at_least(1)

        Facter.fact(:operatingsystemrelease).value
      end
    end
  end

  it "for VMWareESX it should run the vmware -v command" do
    Facter.fact(:kernel).stubs(:value).returns("VMkernel")
    Facter.fact(:kernelrelease).stubs(:value).returns("4.1.0")
    Facter.fact(:operatingsystem).stubs(:value).returns("VMwareESX")

    Facter::Util::Resolution.stubs(:exec).with('vmware -v').returns('foo')

    Facter.fact(:operatingsystemrelease).value
  end

  it "for Alpine it should use the contents of /etc/alpine-release" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:operatingsystem).stubs(:value).returns("Alpine")

    File.expects(:read).with("/etc/alpine-release").returns("foo")

    Facter.fact(:operatingsystemrelease).value.should == "foo"
  end
end
