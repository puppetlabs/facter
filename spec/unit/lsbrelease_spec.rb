#! /usr/bin/env ruby

require 'spec_helper'

describe "lsbrelease fact" do

  [ "Linux", "GNU/kFreeBSD"].each do |kernel|
    describe "on #{kernel}" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns kernel
      end

      it "returns the release through lsb_release -v -s 2>/dev/null" do
        Facter::Core::Execution.impl.stubs(:execute).with('lsb_release -v -s 2>/dev/null', anything).returns 'n/a'
        expect(Facter.fact(:lsbrelease).value).to eq 'n/a'
      end

      it "returns nil if lsb_release is not installed" do
        Facter::Core::Execution.impl.stubs(:expand_command).with('lsb_release -v -s 2>/dev/null').returns nil
        expect(Facter.fact(:lsbrelease).value).to be_nil
      end
    end
  end

end
