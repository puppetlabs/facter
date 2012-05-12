#!/usr/bin/env rspec

require 'spec_helper'

describe "lsbdistid fact" do

  [ "Linux", "GNU/kFreeBSD"].each do |kernel|
    describe "on #{kernel}" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns kernel
      end

      it "should return the id through lsb_release -i -s" do
        Facter::Util::Resolution.stubs(:exec).with('lsb_release -i -s').returns 'Gentoo'
        Facter.fact(:lsbdistid).value.should == 'Gentoo'
      end

      it "should return nil if lsb_release is not installed" do
        Facter::Util::Resolution.stubs(:exec).with('lsb_release -i -s').returns nil
        Facter.fact(:lsbdistid).value.should be_nil
      end
    end
  end

end
