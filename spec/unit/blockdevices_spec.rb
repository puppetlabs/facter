#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'
require 'facter/util/nothing_loader'

describe "Block device facts" do

  describe "on unsupported platforms" do

    it "should not exist when kernel isn't Linux or FreeBSD" do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
      Facter.fact(:blockdevices).should == nil
    end

  end

  describe "on FreeBSD" do

    before :each do
      Facter.fact(:kernel).stubs(:value).returns("FreeBSD")

      Facter::Util::Resolution.stubs(:exec).with("/sbin/sysctl -n kern.disks").returns("cd0 da0 ada0 ad10 mfi0")

      Facter::Util::Resolution.stubs(:exec).with("/sbin/camcontrol inquiry cd0 -D | /usr/bin/awk -F '<|>' '{ print $2 }'").returns("TEAC DV-28E-N 1.6A")
      Facter::Util::Resolution.stubs(:exec).with("/sbin/camcontrol inquiry da0 -D | /usr/bin/awk -F '<|>' '{ print $2 }'").returns("HP 73.4G MAU3073NC HPC2")
      Facter::Util::Resolution.stubs(:exec).with("/sbin/camcontrol identify ada0 | /usr/bin/awk -F 'device\ model\ *' '/device model/ { print $2 }'").returns("Corsair Force GT")
      Facter::Util::Resolution.stubs(:exec).with("/sbin/atacontrol list | /usr/bin/awk -F '<|>' '/ad10/ { print $2 }'").returns("WDC WD1003FBYX-01Y7B0/01.01V01")

      Facter::Util::Resolution.stubs(:exec).with("/usr/sbin/diskinfo da0 | /usr/bin/awk '{ print $3 }'").returns("73407865856")
      Facter::Util::Resolution.stubs(:exec).with("/usr/sbin/diskinfo ada0 | /usr/bin/awk '{ print $3 }'").returns("120034123776")
      Facter::Util::Resolution.stubs(:exec).with("/usr/sbin/diskinfo ad10 | /usr/bin/awk '{ print $3 }'").returns("1000204886016")
      Facter::Util::Resolution.stubs(:exec).with("/usr/sbin/diskinfo mfi0 | /usr/bin/awk '{ print $3 }'").returns("1000000000000")
    end

    describe 'blockdevices fact' do
      it 'should return a sorted list of block devices' do
        Facter.fact(:blockdevices).value.should == 'ad10,ada0,cd0,da0,mfi0'
      end
    end

    describe 'individual block device facts' do

      before :each do
        # We need to manually load this fact file since the fact name varies
        # from the contained file.
        Facter.collection.internal_loader.load(:blockdevices)
      end

      blockdev_tests = {
        'cd0' => {
          :size   => "0",
          :model  => "DV-28E-N 1.6A",
          :vendor => "TEAC",
        },
        'da0' => {
          :model => "73.4G MAU3073NC HPC2",
          :vendor => "HP",
          :size => "73407865856",
        },
        'ada0' => {
          :model => "Force GT",
          :vendor => "Corsair",
          :size => "120034123776",
        },
        'ad10' => {
          :model => "WD1003FBYX-01Y7B0/01.01V01",
          :vendor => "WDC",
          :size => "1000204886016",
        },
        'mfi0' => {
          :model => "Local Disk",
          :vendor => "MFI",
          :size => "1000000000000",
        }
      }

      blockdev_tests.each_pair do |dev, tests|
        tests.each_pair do |name, expected|
          factname = "blockdevice_#{dev}_#{name}"

          it "#{factname} should be #{expected}" do
            Facter.fact(factname).value.should == expected
          end
        end
      end
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
