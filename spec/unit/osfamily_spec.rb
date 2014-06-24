#! /usr/bin/env ruby

require 'spec_helper'

describe "OS Family fact" do

  {
    'Archlinux'    => 'Archlinux',
    'SmartOS'      => 'Solaris',
    'OpenIndiana'  => 'Solaris',
    'OmniOS'       => 'Solaris',
    'Nexenta'      => 'Solaris',
    'Solaris'      => 'Solaris',
    'Ubuntu'       => 'Debian',
    'Debian'       => 'Debian',
    'LinuxMint'    => 'Debian',
    'Gentoo'       => 'Gentoo',
    'Fedora'       => 'RedHat',
    'Amazon'       => 'RedHat',
    'OracleLinux'  => 'RedHat',
    'OVS'          => 'RedHat',
    'OEL'          => 'RedHat',
    'CentOS'       => 'RedHat',
    'SLC'          => 'RedHat',
    'Scientific'   => 'RedHat',
    'CloudLinux'   => 'RedHat',
    'PSBM'         => 'RedHat',
    'Ascendos'     => 'RedHat',
    'XenServer'    => 'RedHat',
    'RedHat'       => 'RedHat',
    'SLES'         => 'Suse',
    'SLED'         => 'Suse',
    'OpenSuSE'     => 'Suse',
    'SuSE'         => 'Suse',
    'Mageia'       => 'Mandrake',
    'Mandriva'     => 'Mandrake',
    'Mandrake'     => 'Mandrake',
  }.each do |os,family|
    it "should return #{family} on operatingsystem #{os}" do
      Facter.fact(:operatingsystem).stubs(:value).returns os
      Facter.fact(:osfamily).value.should == family
    end
  end

  [
    'MeeGo',
    'VMWareESX',
    'Bluewhite64',
    'Slamd64',
    'Slackware',
    'Alpine',
    'ESXi',
    'windows',
    'HP-UX'
  ].each do |os|
    it "should return the kernel fact on operatingsystem #{os}" do
      Facter.fact(:operatingsystem).stubs(:value).returns os
      Facter.fact(:kernel).stubs(:value).returns 'random_kernel_fact'
      Facter.fact(:osfamily).value.should == 'random_kernel_fact'
    end
  end
end
