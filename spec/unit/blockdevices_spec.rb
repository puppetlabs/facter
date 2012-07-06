#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'
require 'facter/util/nothing_loader'

describe "Block device facts" do

  describe "on non-Linux OS" do

    it "should not exist when kernel isn't Linux" do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
      Facter.fact(:blockdevices).should == nil
    end

  end

  describe "on Linux" do

    describe "with /sys/block/" do

      describe "with valid entries" do
        before :each do
          Facter::Util::Config.ext_fact_loader = Facter::Util::NothingLoader.new
          Facter.fact(:kernel).stubs(:value).returns("Linux")
          File.stubs(:exist?).with('/sys/block/').returns(true)

          Dir.stubs(:entries).with("/sys/block/").returns([".", "..", "hda", "sda", "sdb"])

          File.stubs(:exist?).with("/sys/block/./device").returns(false)
          File.stubs(:exist?).with("/sys/block/../device").returns(false)

          stubdevices = [
            #device,    size,               vendor,     model
            ["hda"],
            ["sda",     "976773168",        "ATA",      "WDC WD5000AAKS-0"],
            ["sdb",     "8787591168",       "DELL",     "PERC H700"]
          ]

          stubdevices.each do |device, size, vendor, model|
            stubdir = "/sys/block/#{device}"
            File.stubs(:exist?).with(stubdir + "/device").returns(true)
            File.stubs(:exist?).with(stubdir + "/size").returns(size ? true : false)
            File.stubs(:exist?).with(stubdir + "/device/model").returns(model ? true : false)
            File.stubs(:exist?).with(stubdir + "/device/vendor").returns(vendor ? true : false)
            IO.stubs(:read).with(stubdir + "/size").returns(size) if size
            IO.stubs(:read).with(stubdir + "/device/vendor").returns(vendor) if vendor
            IO.stubs(:read).with(stubdir + "/device/model").returns(model) if model
          end
        end

        it "should report three block devices, hda, sda, and sdb, with accurate information from sda and sdb, and without invalid . or .. entries" do
          Facter.fact(:blockdevices).value.should == "hda,sda,sdb"

          # handle facts that should not exist
          %w{ . .. hda }.each do |device|
            Facter.fact("blockdevice_#{device}_size".to_sym).should == nil
            Facter.fact("blockdevice_#{device}_vendor".to_sym).should == nil
            Facter.fact("blockdevice_#{device}_model".to_sym).should == nil
          end

          # handle facts that should exist
          %w{ sda sdb }.each do |device|
            Facter.fact("blockdevice_#{device}_size".to_sym).should_not == nil
            Facter.fact("blockdevice_#{device}_vendor".to_sym).should_not == nil
            Facter.fact("blockdevice_#{device}_model".to_sym).should_not == nil
          end

          Facter.fact(:blockdevice_sda_model).value.should == "WDC WD5000AAKS-0"
          Facter.fact(:blockdevice_sda_vendor).value.should == "ATA"
          Facter.fact(:blockdevice_sda_size).value.should == 500107862016

          Facter.fact(:blockdevice_sdb_model).value.should == "PERC H700"
          Facter.fact(:blockdevice_sdb_vendor).value.should == "DELL"
          Facter.fact(:blockdevice_sdb_size).value.should == 4499246678016

        end

      end
      describe "with invalid entries in /sys/block" do
        before :each do
          Facter.fact(:kernel).stubs(:value).returns("Linux")
          File.stubs(:exist?).with('/sys/block/').returns(true)

          Dir.stubs(:entries).with("/sys/block/").returns([".", "..", "xda", "ydb"])

          File.stubs(:exist?).with("/sys/block/./device").returns(false)
          File.stubs(:exist?).with("/sys/block/../device").returns(false)
          File.stubs(:exist?).with("/sys/block/xda/device").returns(false)
          File.stubs(:exist?).with("/sys/block/ydb/device").returns(false)
        end

        it "should not exist with invalid entries in /sys/block" do
          Facter.fact(:blockdevices).should == nil
        end
      end
    end
    describe "without /sys/block/" do

      it "should not exist without /sys/block/ on Linux" do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        File.stubs(:exist?).with('/sys/block/').returns(false)
        Facter.fact(:blockdevices).should == nil
      end

    end

  end
end
