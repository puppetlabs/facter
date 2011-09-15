#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'facter'

describe "Memory facts" do
    before do
        # We need these facts loaded, but they belong to a file with a
        # different name, so load the file explicitly.
        Facter.collection.loader.load(:memory)
    end

    after do
        Facter.clear
    end

    it "should return the current swap size" do

        Facter.fact(:kernel).stubs(:value).returns("Darwin")
        Facter::Util::Resolution.stubs(:exec).with('sysctl vm.swapusage').returns("vm.swapusage: total = 64.00M  used = 0.00M  free = 64.00M  (encrypted)")
        swapusage = "vm.swapusage: total = 64.00M  used = 0.00M  free = 64.00M  (encrypted)"

        if swapusage =~ /total = (\S+).*/
            Facter.fact(:swapfree).value.should == $1
        end
    end

    it "should return the current swap free" do
        Facter.fact(:kernel).stubs(:value).returns("Darwin")
        Facter::Util::Resolution.stubs(:exec).with('sysctl vm.swapusage').returns("vm.swapusage: total = 64.00M  used = 0.00M  free = 64.00M  (encrypted)")
        swapusage = "vm.swapusage: total = 64.00M  used = 0.00M  free = 64.00M  (encrypted)"

        if swapusage =~ /free = (\S+).*/
            Facter.fact(:swapfree).value.should == $1
        end
    end

    it "should return whether swap is encrypted" do
        Facter.fact(:kernel).stubs(:value).returns("Darwin")
        Facter::Util::Resolution.stubs(:exec).with('sysctl vm.swapusage').returns("vm.swapusage: total = 64.00M  used = 0.00M  free = 64.00M  (encrypted)")
        swapusage = "vm.swapusage: total = 64.00M  used = 0.00M  free = 64.00M  (encrypted)"

        swapusage =~ /\(encrypted\)/
	Facter.fact(:swapencrypted).value.should == true
    end
end
