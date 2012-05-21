#!/usr/bin/env rspec

require 'spec_helper'

describe "lsbdistcodename fact" do

  [ "Linux", "GNU/kFreeBSD"].each do |kernel|
    describe "on #{kernel}" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns kernel
      end

      it "should return the codename through lsb_release -c -s 2>/dev/null" do
        Facter::Util::Resolution.stubs(:exec).with('lsb_release -c -s 2>/dev/null').returns 'n/a'
        Facter.fact(:lsbdistcodename).value.should == 'n/a'
      end

      it "should return nil if lsb_release is not installed" do
        Facter::Util::Resolution.stubs(:exec).with('lsb_release -c -s 2>/dev/null').returns nil
        Facter.fact(:lsbdistcodename).value.should be_nil
      end
    end
  end

end
