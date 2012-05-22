#!/usr/bin/env rspec

require 'spec_helper'

describe "OS Family fact" do

  {
    'Ubuntu'      => 'Debian',
    'Debian'      => 'Debian',
    'Funtoo'      => 'Gentoo',
    'Gentoo'      => 'Gentoo',
    'Fedora'      => 'RedHat',
    'CentOS'      => 'RedHat',
    'SLC'         => 'RedHat',
    'Scientific'  => 'RedHat',
    'CloudLinux'  => 'RedHat',
    'PSBM'        => 'RedHat',
    'Ascendos'    => 'RedHat',
    'RedHat'      => 'RedHat',
    'OracleLinux' => 'RedHat',
    'OVS'         => 'RedHat',
    'OEL'         => 'RedHat',
    'SLES'        => 'Suse',
    'SLED'        => 'Suse',
    'OpenSuSE'    => 'Suse',
    'SuSE'        => 'Suse',
    'Nexenta'     => 'Solaris',
    'Solaris'     => 'Solaris'
  }.each do |os,family|
    it "should return #{family} on operatingsystem #{os}" do
      Facter.fact(:operatingsystem).stubs(:value).returns os
      Facter.fact(:osfamily).value.should == family
    end
  end

  [
    'Mandriva',
    'Mandrake',
    'MeeGo',
    'Archlinux',
    'VMWareESX',
    'Bluewhite64',
    'Slamd64',
    'Slackware',
    'Alpine',
    'Amazon',
    'ESXi'
  ].each do |os|
    it "should return the kernel fact on operatingsystem #{os}" do
      Facter.fact(:operatingsystem).stubs(:value).returns os
      Facter.fact(:kernel).stubs(:value).returns 'random_kernel_fact'
      Facter.fact(:osfamily).value.should == 'random_kernel_fact'
    end
  end
end
