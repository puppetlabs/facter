#! /usr/bin/env ruby

require 'spec_helper'

describe "FIPS Facts" do
  describe "should detect if FIPS is enabled" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
    end

    it "returns true if fips is enabled on the system" do
      File.stubs(:read).with("/proc/sys/crypto/fips_enabled").returns("1")
      File.expects(:read).with("/proc/sys/crypto/fips_enabled").returns("1")

      Facter.fact(:fips_enabled).value.should == "true"
    end
  end
end
