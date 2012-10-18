#! /usr/bin/env ruby

require 'spec_helper'

describe "lsbrelease fact" do

  [ "Linux", "GNU/kFreeBSD"].each do |kernel|
    describe "on #{kernel}" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns kernel
      end

      it "should return the release through lsb_release -v -s 2>/dev/null" do
        Facter::Util::Resolution.stubs(:exec).with('lsb_release -v -s 2>/dev/null').returns 'n/a'
        Facter.fact(:lsbrelease).value.should == 'n/a'
      end

      it "should return nil if lsb_release is not installed" do
        Facter::Util::Resolution.stubs(:exec).with('lsb_release -v -s 2>/dev/null').returns nil
        Facter.fact(:lsbrelease).value.should be_nil
      end
    end
  end

end
