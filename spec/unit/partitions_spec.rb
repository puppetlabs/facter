#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "Partition facts" do

  describe "on unsupported platforms" do

    it "should not exist" do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
      Facter.fact(:partitions).value.should == nil
    end
  end

  describe "on Linux" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
    end

    it "should return a structured fact with uuid, size, label (if available), mount point and filesytem for each partition" do
      partitions = {
        'sda1' => {
          'uuid'       => '13459663-22cc-47b4-a9e6-21dea9906e03',
          'size'       => '1234',
          'mount'      => '/',
          'filesystem' => 'ext4',
        },
        'sdb2' => {
          'uuid'       => '98043570-eb10-457f-9718-0b85a26e66bf',
          'size'       => '5678',
          'label'      => 'homes',
          'mount'      => '/home',
          'filesystem' => 'xfs',
        },
      }

      Facter::Util::Partitions.stubs(:list).returns(partitions.keys)

      partitions.each do |part,vals|
        Facter::Util::Partitions.stubs(:uuid).with(part).returns(vals['uuid'])
        Facter::Util::Partitions.stubs(:size).with(part).returns(vals['size'])
        Facter::Util::Partitions.stubs(:label).with(part).returns(vals['label'])
        Facter::Util::Partitions.stubs(:mount).with(part).returns(vals['mount'])
        Facter::Util::Partitions.stubs(:filesystem).with(part).returns(vals['filesystem'])
      end

      Facter.fact(:partitions).value.should == {
        'sda1' => { 'uuid' => '13459663-22cc-47b4-a9e6-21dea9906e03', 'size' => '1234', 'mount' => '/', 'filesystem' => 'ext4' },
        'sdb2' => { 'uuid' => '98043570-eb10-457f-9718-0b85a26e66bf', 'size' => '5678', 'label' => 'homes', 'mount' => '/home', 'filesystem' => 'xfs' },
      }
    end
  end

  describe "on OpenBSD" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("OpenBSD")
    end

    it "should return a structured fact with size, mount point and filesystem for each partition" do
      partitions = {
        'sd2a' => {
          'size'       => '1234',
          'mount'      => '/',
          'filesystem' => 'ffs',
        },
        'sd2d' => {
          'size'       => '4321',
          'mount'      => '/usr',
          'filesystem' => 'ffs2',
        },
      }

      Facter::Util::Partitions.stubs(:list).returns(partitions.keys)

      partitions.each do |part,vals|
        Facter::Util::Partitions.stubs(:size).with(part).returns(vals['size'])
        Facter::Util::Partitions.stubs(:mount).with(part).returns(vals['mount'])
        Facter::Util::Partitions.stubs(:filesystem).with(part).returns(vals['filesystem'])
      end

      Facter.fact(:partitions).value.should == {
        'sd2a' => { 'size' => '1234', 'mount' => '/', 'filesystem' => 'ffs' },
        'sd2d' => { 'size' => '4321', 'mount' => '/usr', 'filesystem' => 'ffs2' },
      }
    end
  end
end
