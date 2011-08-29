#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'facter'

describe "Processor facts" do
  describe "on Windows" do
    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("windows")
    end

    def load(procs)
      require 'facter/util/wmi'
      Facter::Util::WMI.stubs(:execquery).with("select * from Win32_Processor").returns(procs)

      # processor facts belong to a file with a different name,
      # so load the file explicitly (after stubbing kernel),
      # but we have to stub execquery first
      Facter.collection.loader.load(:processor)
    end

    describe "2003" do
      before :each do
        proc = stubs 'proc'
        proc.stubs(:NumberOfLogicalProcessors).raises(RuntimeError)
        proc.stubs(:Name).returns("Intel(R)    Celeron(R)   processor")

        load(Array.new(2, proc))
      end

      it "should count 2 processors" do
        Facter.fact(:processorcount).value.should == "2"
      end

      it "should squeeze the processor name 2 times" do
        2.times do |i|
          Facter.fact("processor#{i}".to_sym).value.should == "Intel(R) Celeron(R) processor"
        end
      end
    end

    describe "2008" do
      before :each do
        proc = stubs 'proc'
        proc.stubs(:NumberOfLogicalProcessors).returns(2)
        proc.stubs(:Name).returns("Intel(R)    Celeron(R)   processor")

        load(Array.new(2, proc))
      end

      it "should count 4 processors" do
        Facter.fact(:processorcount).value.should == "4"
      end

      it "should squeeze the processor name 4 times" do
        4.times do |i|
          Facter.fact("processor#{i}".to_sym).value.should == "Intel(R) Celeron(R) processor"
        end
      end
    end
  end
end


