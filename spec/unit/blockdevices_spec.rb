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

          #Stubs relating to the Partition UUID facts
          File.stubs(:exist?).with('/dev/disk/by-uuid/').returns(true)

          Dir.stubs(:glob).with("/sys/block/hda/hda*").returns([])

          Dir.stubs(:glob).with("/sys/block/sda/sda*").returns([
            '/sys/block/sda/sda1',
            '/sys/block/sda/sda2',
          ])

          Dir.stubs(:glob).with("/sys/block/sdb/sdb*").returns([
            '/sys/block/sda/sdb1',
            '/sys/block/sda/sdb2',
          ])

          File.stubs(:directory?).returns(true)

          Dir.stubs(:entries).with('/dev/disk/by-uuid/').returns([
            ".",                                    #wont match the length requirements
            "..",                                   #wont match the length requirements
            "11111111-1111-1111-1111-111111111111", #Should be valid
            "22222222-2222-2222-2222-222222222222", #Should be valid
            "33333333-3333-3333-3333-333333333333", #Should be valid
            "44444444-4444-4444-4444-444444444444", #Wont match the link regex
            "55555555-5555-5555-5555-555555555555"  #Wont be a symlink
          ])

          File.stubs(:readlink).with('/dev/disk/by-uuid/11111111-1111-1111-1111-111111111111').returns('../../sda1')
          File.stubs(:readlink).with('/dev/disk/by-uuid/22222222-2222-2222-2222-222222222222').returns('../../sda2')
          File.stubs(:readlink).with('/dev/disk/by-uuid/33333333-3333-3333-3333-333333333333').returns('../../sdb1')
          File.stubs(:readlink).with('/dev/disk/by-uuid/44444444-4444-4444-4444-444444444444').returns('/dont/match/regex/sdb2')

          File.stubs(:symlink?).with('/dev/disk/by-uuid/11111111-1111-1111-1111-111111111111').returns(true)
          File.stubs(:symlink?).with('/dev/disk/by-uuid/22222222-2222-2222-2222-222222222222').returns(true)
          File.stubs(:symlink?).with('/dev/disk/by-uuid/33333333-3333-3333-3333-333333333333').returns(true)
          File.stubs(:symlink?).with('/dev/disk/by-uuid/44444444-4444-4444-4444-444444444444').returns(true)
          File.stubs(:symlink?).with('/dev/disk/by-uuid/55555555-5555-5555-5555-555555555555').returns(false)
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
            Facter.fact("blockdevice_#{device}_partitions".to_sym).should_not == nil
          end

          Facter.fact(:blockdevice_sda_model).value.should == "WDC WD5000AAKS-0"
          Facter.fact(:blockdevice_sda_vendor).value.should == "ATA"
          Facter.fact(:blockdevice_sda_size).value.should == 500107862016
          Facter.fact(:blockdevice_sda_partitions).value.should == 'sda1,sda2'

          Facter.fact(:blockdevice_sdb_model).value.should == "PERC H700"
          Facter.fact(:blockdevice_sdb_vendor).value.should == "DELL"
          Facter.fact(:blockdevice_sdb_size).value.should == 4499246678016
          Facter.fact(:blockdevice_sdb_partitions).value.should == 'sdb1,sdb2'

          #These partitions should have a UUID
          %w{ sda1 sda2 sdb1 }.each do |d|
            Facter.value("blockdevice_#{d}_uuid".to_sym).should_not == nil
          end

          #These should not create a UUID fact
          [ ".", "..", "sdb2" ].each do |d|
            Facter.value("partition_#{d}_uuid".to_sym).should == nil
          end

          Facter.fact(:blockdevice_sda1_uuid).value.should == "11111111-1111-1111-1111-111111111111"
          Facter.fact(:blockdevice_sda2_uuid).value.should == "22222222-2222-2222-2222-222222222222"
          Facter.fact(:blockdevice_sdb1_uuid).value.should == "33333333-3333-3333-3333-333333333333"
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

          #This is here to surpress errors when Dir.entries is run in relation to uuids
          Dir.stubs(:entries).with('/dev/disk/by-uuid/').returns([])
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
