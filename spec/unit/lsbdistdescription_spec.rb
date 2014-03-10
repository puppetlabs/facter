#! /usr/bin/env ruby

require 'spec_helper'

describe "lsbdistdescription fact" do

  [ "Linux", "GNU/kFreeBSD"].each do |kernel|
    describe "on #{kernel}" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns kernel
      end

      it "returns the description through lsb_release -d -s 2>/dev/null" do
        Facter::Core::Execution.stubs(:which).with('lsb_release').returns '/usr/bin/lsb_release'
        Facter::Core::Execution.stubs(:exec).with('lsb_release -d -s 2>/dev/null', anything).returns '"Gentoo Base System release 2.1"'
        expect(Facter.fact(:lsbdistdescription).value).to eq 'Gentoo Base System release 2.1'
      end

      it "returns nil if lsb_release is not installed" do
        Facter::Core::Execution.stubs(:which).with('lsb_release').returns nil
        expect(Facter.fact(:lsbdistdescription).value).to be_nil
      end
    end
  end
end
