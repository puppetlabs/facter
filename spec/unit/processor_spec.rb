#! /usr/bin/env ruby

require 'spec_helper'

describe "Processor facts" do
  describe "processorX facts" do
    expected_proc_list = ["Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz", "Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz"]

    ["aix", "hp-ux", "sunos", "linux", "gnu/kfreebsd"].each do |kernel|
      it "should use the 'models' key from the 'processors' fact on #{kernel}" do
        Facter.fact(:kernel).stubs(:value).returns("#{kernel}")
        Facter.fact("processors").stubs(:value).returns({"count" => 8, "physicalcount" => 4, "models" => expected_proc_list})
        Facter.collection.internal_loader.load(:processor)
        expected_proc_list.each_with_index do |processor, i|
          Facter.fact("processor#{i}").value.should eq processor
        end
      end
    end
  end

  describe "processorcount" do
    it "should use the 'processorcount' key from the 'processors' fact" do
      Facter.fact(:kernel).stubs(:value).returns("linux")
      Facter.fact("processors").stubs(:value).returns({"count" => 8, "physicalcount" => 4 })
      Facter.collection.internal_loader.load(:processor)
      Facter.fact(:processorcount).value.should eq 8
    end
  end

  describe "processor" do
    it "should print the correct CPU Model on OpenBSD" do
      Facter.collection.internal_loader.load(:processor)
      Facter.fact(:kernel).stubs(:value).returns("OpenBSD")
      Facter::Util::POSIX.stubs(:sysctl).with("hw.model").returns('SomeVendor CPU 4.2GHz')
      Facter.fact(:processor).value.should eq "SomeVendor CPU 4.2GHz"
    end
  end
end
