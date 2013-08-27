#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "host UUID fact" do
  it "should match kern.hostuuid on FreeBSD" do
    Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
    Facter::Util::POSIX.stubs(:sysctl).with("kern.hostuuid").returns("a0391b10-6c8c-11e1-b960-001b21b8d7b0")

    Facter.fact(:hostuuid).value.should == "a0391b10-6c8c-11e1-b960-001b21b8d7b0"
  end
end
