#! /usr/bin/env ruby

require 'spec_helper'

describe "Processor facts" do
  describe "processorX facts" do
    ["aix", "hp-ux", "sunos", "linux", "gnu/kfreebsd"].each do |kernel|
      expected_proc_list = {"Processor0"=>"Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz", "Processor1"=>"Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz"}
      Facter.fact(:kernel).stubs(:value).returns("#{kernel}")
      Facter.fact("processors").stubs(:value).returns({"processorcount" => "8", "physicalprocessorcount" => "4", "processorlist" => expected_proc_list})
      Facter.collection.internal_loader.load(:processor)
      expected_proc_list.each_with_index do |(key, value), i|
        Facter.fact("processor#{i}").value.should == value
      end
    end
  end

  describe "processorcount" do
    it "should use the 'processorcount' key from the 'processors' fact" do
      Facter.fact(:kernel).stubs(:value).returns("linux")
      Facter.fact("processors").stubs(:value).returns({"processorcount" => "8", "physicalprocessorcount" => "4" })
      Facter.collection.internal_loader.load(:processor)
      Facter.fact(:processorcount).value.should == "8"
    end
  end

  describe "processor" do
    it "should use the 'processor' key from the 'processors' fact" do
      Facter.fact(:kernel).stubs(:value).returns("OpenBSD")
      Facter.fact("processors").stubs(:value).returns({"processorcount" => "8", "physicalprocessorcount" => "4", "processor" => "SomeVendor 2.4 GHz" })
      Facter.collection.internal_loader.load(:processor)
      Facter.fact(:processor).value.should == "SomeVendor 2.4 GHz"
    end
  end
end
