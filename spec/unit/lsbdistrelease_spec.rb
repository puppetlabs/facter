#! /usr/bin/env ruby

require 'spec_helper'

describe "lsbdistrelease fact" do

  [ "Linux", "GNU/kFreeBSD"].each do |kernel|
    describe "on #{kernel}" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns kernel
      end

      it "should return the release through lsb_release -r -s 2>/dev/null" do
        Facter::Util::Resolution.stubs(:exec).with('lsb_release -r -s 2>/dev/null').returns '2.1'
        Facter.fact(:lsbdistrelease).value.should == '2.1'
      end

      it "should return nil if lsb_release is not installed" do
        Facter::Util::Resolution.stubs(:exec).with('lsb_release -r -s 2>/dev/null').returns nil
        Facter.fact(:lsbdistrelease).value.should be_nil
      end
    end
  end

end
