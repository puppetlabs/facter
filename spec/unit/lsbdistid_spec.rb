#! /usr/bin/env ruby

require 'spec_helper'

describe "lsbdistid fact" do

  [ "Linux", "GNU/kFreeBSD"].each do |kernel|
    describe "on #{kernel}" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns kernel
      end

      it "returns the id through lsb_release -i -s 2>/dev/null" do
        Facter::Core::Execution.impl.stubs(:execute).with('lsb_release -i -s 2>/dev/null', anything).returns 'Gentoo'
        expect(Facter.fact(:lsbdistid).value).to eq 'Gentoo'
      end

      it "returns nil if lsb_release is not installed" do
        Facter::Core::Execution.impl.stubs(:expand_command).with('lsb_release -i -s 2>/dev/null').returns nil
        expect(Facter.fact(:lsbdistid).value).to be_nil
      end
    end
  end

end
