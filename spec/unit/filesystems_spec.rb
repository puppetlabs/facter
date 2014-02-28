#! /usr/bin/env ruby

require 'spec_helper'

describe 'Filesystem facts' do
  describe 'on non-Linux OS' do
    it 'should not exist' do
      Facter.fact(:kernel).stubs(:value).returns('SunOS')
      Facter.fact(:filesystems).value.should == nil
    end
  end

  describe 'on Linux' do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns('Linux')
      fixture_data = my_fixture_read('linux')
      Facter::Core::Execution.expects(:exec) \
        .with('cat /proc/filesystems 2> /dev/null').returns(fixture_data)
      Facter.collection.internal_loader.load(:filesystems)
    end

    after :each do
      Facter.clear
    end

    it 'should exist' do
      Facter.fact(:filesystems).value.should_not == nil
    end

    it 'should detect the correct number of filesystems' do
      Facter.fact(:filesystems).value.split(',').length.should == 6
    end

    # Check that lines from /proc/filesystems that start with 'nodev' are
    # skipped
    it 'should not detect sysfs' do
      Facter.fact(:filesystems).value.split(',').should_not include('sysfs')
    end

    # Check that all other lines are counted as valid filesystems
    it 'should detect ext4' do
      Facter.fact(:filesystems).value.split(',').should include('ext4')
    end

    # fuseblk is never included in the filesystem list
    it 'should not detect fuseblk' do
      Facter.fact(:filesystems).value.split(',').should_not include('fuseblk')
    end
  end
end
