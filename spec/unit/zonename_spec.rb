#! /usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "zonename fact" do

  it "should return global zone" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter::Core::Execution.stubs(:execute).with("zonename", anything).returns('global')

    Facter.fact(:zonename).value.should == "global"
  end
end
