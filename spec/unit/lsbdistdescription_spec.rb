#!/usr/bin/env rspec

require 'spec_helper'

describe "lsbdistdescription fact" do

  [ "Linux", "GNU/kFreeBSD"].each do |kernel|
    describe "on #{kernel}" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns kernel
      end

      it "should return the description through lsb_release -d -s" do
        Facter::Util::Resolution.stubs(:exec).with('lsb_release -d -s').returns '"Gentoo Base System release 2.1"'
        Facter.fact(:lsbdistdescription).value.should == 'Gentoo Base System release 2.1'
      end

      it "should return nil if lsb_release is not installed" do
        Facter::Util::Resolution.stubs(:exec).with('lsb_release -d -s').returns nil
        Facter.fact(:lsbdistdescription).value.should be_nil
      end
    end
  end

end
