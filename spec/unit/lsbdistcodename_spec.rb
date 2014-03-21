#! /usr/bin/env ruby

require 'spec_helper'

describe "lsbdistcodename fact" do

  [ "Linux", "GNU/kFreeBSD"].each do |kernel|
    describe "on #{kernel}" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns kernel
      end

      it "returns the codename through lsb_release -c -s 2>/dev/null" do
        Facter::Core::Execution.impl.stubs(:execute).with('lsb_release -c -s 2>/dev/null', anything).returns 'n/a'
        expect(Facter.fact(:lsbdistcodename).value).to eq 'n/a'
      end

      it "returns nil if lsb_release is not installed" do
        Facter::Core::Execution.impl.stubs(:expand_command).with('lsb_release -c -s 2>/dev/null').returns nil
        expect(Facter.fact(:lsbdistcodename).value).to be_nil
      end
    end
  end

end
