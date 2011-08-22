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

    describe "on Windows" do
        before :each do
             Facter.clear
             Facter.fact(:kernel).stubs(:value).returns("windows")
             Facter.collection.loader.load(:memory)

             require 'facter/util/wmi'
        end

        it "should return free memory" do
             os = stubs 'os'
             os.stubs(:FreePhysicalMemory).returns("3415624")
             Facter::Util::WMI.stubs(:execquery).returns([os])

             Facter.fact(:MemoryFree).value.should == '3.26 GB'
        end

        it "should return total memory" do
             computer = stubs 'computer'
             computer.stubs(:TotalPhysicalMemory).returns("4193837056")
             Facter::Util::WMI.stubs(:execquery).returns([computer])

             Facter.fact(:MemoryTotal).value.should == '3.91 GB'
        end
    end
end
