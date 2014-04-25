#! /usr/bin/env ruby

require 'spec_helper'

describe "Kernel major version fact" do
  context "when the kernelrelease fact contains three components" do
    it "returns the first two components" do
      Facter.fact(:kernelversion).stubs(:value).returns("12.34.56")

      Facter.fact(:kernelmajversion).value.should == "12.34"
    end
  end

  context "when the kernelrelease fact only contains two components" do
    it "returns the first component" do
      Facter.fact(:kernel).stubs(:value).returns('FreeBSD')
      Facter.fact(:kernelversion).stubs(:value).returns("9.2")

      Facter.fact(:kernelmajversion).value.should == "9"
    end
  end
end
