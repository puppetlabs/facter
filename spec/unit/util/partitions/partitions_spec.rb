require 'spec_helper'
require 'facter'
require 'facter/util/partitions/linux'

describe 'Facter::Util::Partitions::Linux' do
  describe 'on Linux OS' do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")

      File.stubs(:exist?).with('/sys/block/').returns(true)
      File.stubs(:exist?).with("/sys/block/./device").returns(false)
      File.stubs(:exist?).with("/sys/block/../device").returns(false)
      File.stubs(:exist?).with('/dev/disk/by-uuid/').returns(true)

      devices = [".", "..", "sda", "sdb", "sdc"]
      Dir.stubs(:entries).with('/sys/block/').returns(devices)
      
      Facter::Core::Execution.stubs(:which).with('mount').returns(true)
      Facter::Core::Execution.stubs(:which).with('blkid').returns(true)

      test_parts = {
        'sda1' => '13459663-22cc-47b4-a9e6-21dea9906e03',  
        'sdb2' => '98043570-eb10-457f-9718-0b85a26e66bf',  
        'sdc3' => 'a35fb506-e831-4752-9899-dff6c601214b',
      }
      
      Dir.stubs(:entries).with('/dev/disk/by-uuid/').returns(test_parts.values)
      test_parts.each do |part,uuid|
        device = part.match(/(\D+)/)[1]
        File.stubs(:exist?).with("/sys/block/#{device}/device").returns(true)
        File.stubs(:symlink?).with("/dev/disk/by-uuid/#{uuid}").returns(true)
        File.stubs(:readlink).with("/dev/disk/by-uuid/#{uuid}").returns("/dev/#{part}")
        Dir.stubs(:glob).with("/sys/block/#{device}/#{device}*").returns(["/sys/block/#{device}/#{part}"])
        Facter::Util::Partitions::Linux.stubs(:read_size).returns('12345')
        Facter::Core::Execution.stubs(:exec).with("blkid /dev/#{part}").returns("/dev/#{part}: UUID=\"#{uuid}\" TYPE=\"ext4\"")
      end

      Facter::Core::Execution.stubs(:exec).with('mount').returns(my_fixture_read("mount"))
    end

    it '.list should return a list of partitions' do
      Facter::Util::Partitions::Linux.list.should == ['sda1', 'sdb2', 'sdc3']
    end

    it '.uuid should return a string containing the uuid' do
      Facter::Util::Partitions::Linux.uuid('sda1').should == '13459663-22cc-47b4-a9e6-21dea9906e03'
      Facter::Util::Partitions::Linux.uuid('sdb2').should == '98043570-eb10-457f-9718-0b85a26e66bf'
      Facter::Util::Partitions::Linux.uuid('sdc3').should == 'a35fb506-e831-4752-9899-dff6c601214b'
    end

    it '.size should return a string containing the size' do
      Facter::Util::Partitions::Linux.size('sda1').should == '12345'
    end

    it '.mount should return a string containing the mount point of the partition' do
      Facter::Util::Partitions::Linux.mount('sda1').should == '/home'
      Facter::Util::Partitions::Linux.mount('sdb2').should == '/'
      Facter::Util::Partitions::Linux.mount('sdc3').should == '/var'
    end

    it '.filesystem should return a string containing the filesystem on the partition' do
      Facter::Util::Partitions::Linux.filesystem('sda1').should == 'ext4'
      Facter::Util::Partitions::Linux.filesystem('sdb2').should == 'ext4'
      Facter::Util::Partitions::Linux.filesystem('sdc3').should == 'ext4'
    end
  end
end
