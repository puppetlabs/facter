#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "Partition facts" do

  describe "on non-Linux OS" do

    it "should not exist when kernel isn't Linux" do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
      Facter.fact(:partitions).value.should == nil
    end
  end

  describe "on Linux" do
    it "should return a structured fact with uuid, size, mount point and filesytem for each partition" do
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
          'mount'      => '/home',
          'filesystem' => 'xfs',
        },
      }

      Facter::Util::Partitions.stubs(:list).returns( partitions.keys )

      partitions.each do |part,vals|
        Facter::Util::Partitions.stubs(:uuid).with(part).returns(vals['uuid'])
        Facter::Util::Partitions.stubs(:size).with(part).returns(vals['size'])
        Facter::Util::Partitions.stubs(:mount).with(part).returns(vals['mount'])
        Facter::Util::Partitions.stubs(:filesystem).with(part).returns(vals['filesystem'])
      end

      Facter.fact(:partitions).value.should == {
        'sda1' => { 'uuid' => '13459663-22cc-47b4-a9e6-21dea9906e03', 'size' => '1234', 'mount' => '/', 'filesystem' => 'ext4' },
        'sdb2' => { 'uuid' => '98043570-eb10-457f-9718-0b85a26e66bf', 'size' => '5678', 'mount' => '/home', 'filesystem' => 'xfs' },
      }
    end
  end
end
