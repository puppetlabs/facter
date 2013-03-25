#! /usr/bin/env ruby

require 'spec_helper'

describe "ps facts" do

  it "should return busybox style ps www on OpenWrt" do
    Facter.fact(:operatingsystem).stubs(:value).returns 'OpenWrt'
    Facter.fact(:ps).value.should == 'ps www'
  end

  [
    'FreeBSD',
    'NetBSD',
    'OpenBSD',
    'Darwin',
    'DragonFly'
  ].each do |os|
    it "should return unix style ps on operatingsystem #{os}" do
      Facter.fact(:operatingsystem).stubs(:value).returns os
      Facter.fact(:ps).value.should == 'ps auxwww'
    end
  end

  # Other Linux Distros should return a ps -ef
  [
    'RedHat',
    'Debian',
  ].each do |os|
    it "should return gnu/linux style ps -ef on operatingsystem #{os}" do
      Facter.fact(:operatingsystem).stubs(:value).returns os
      Facter.fact(:ps).value.should == 'ps -ef'
    end
  end

  it "should return tasklist.exe on Windows" do
    Facter.fact(:operatingsystem).stubs(:value).returns 'windows'
    Facter.fact(:ps).value.should == 'tasklist.exe'
  end

end

