#! /usr/bin/env ruby

require 'spec_helper'

describe "fqdn fact" do
  it "should concatenate hostname and domain" do
    Facter.fact(:hostname).stubs(:value).returns("foo")
    Facter.fact(:domain).stubs(:value).returns("bar")
    Facter.fact(:fqdn).value.should == "foo.bar"
  end
  it "should return hostname when domain is nil" do
    Facter.fact(:hostname).stubs(:value).returns("foo")
    Facter.fact(:domain).stubs(:value).returns(nil)
    Facter.fact(:fqdn).value.should == "foo"
  end
end
