#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "Uniqueid fact" do
  it "should match hostid on Solaris" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter::Core::Execution.stubs(:execute).with("hostid", anything).returns("Larry")

    Facter.fact(:uniqueid).value.should == "Larry"
  end

  it "should match hostid on Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter::Core::Execution.stubs(:execute).with("hostid", anything).returns("Curly")

    Facter.fact(:uniqueid).value.should == "Curly"
  end

  it "should match hostid on AIX" do
    Facter.fact(:kernel).stubs(:value).returns("AIX")
    Facter::Core::Execution.stubs(:execute).with("hostid", anything).returns("Moe")

    Facter.fact(:uniqueid).value.should == "Moe"
  end
end
