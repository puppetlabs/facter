#! /usr/bin/env ruby

require 'facter/util/file_read'
require 'spec_helper'

describe "Operating System Release fact" do

  before do
    Facter.clear
  end

  after do
    Facter.clear
  end

  # We don't currently have fixtures for these releases.
  no_fixtures = {
    "Fedora"      => { :path => "/etc/fedora-release" },
    "LinuxMint"   => { :path => "/etc/linuxmint/info" },
    "MeeGo"       => { :path => "/etc/meego-release" },
    "OEL"         => { :path => "/etc/enterprise-release" },
    "oel"         => { :path => "/etc/enterprise-release" },
    "OVS"         => { :path => "/etc/ovs-release" },
    "ovs"         => { :path => "/etc/ovs-release" },
    "OracleLinux" => { :path => "/etc/oracle-release" },
    'OpenWrt'     => { :path => '/etc/openwrt_version' },
    "Scientific"  => { :path => "/etc/redhat-release" }
  }

  no_fixtures.each do |system, file_data|
    describe "with operatingsystem #{system.inspect}" do
      it "reads the #{file_data[:path].inspect} file" do
        Facter.fact(:operatingsystem).stubs(:value).returns(system)
        Facter::Util::FileRead.expects(:read).with(file_data[:path]).at_least_once
        Facter.fact(:operatingsystemrelease).value
      end
    end
  end

  with_fixtures = {
    "CentOS"    => {
      :path => "/etc/redhat-release",
      :expected_value => '5.6'
    },
    "RedHat"    => {
      :path => "/etc/redhat-release",
      :expected_value => '6.0'
    },
    "Ascendos"    => {
      :path => "/etc/redhat-release",
      :expected_value => '6.0'
    },
    "CloudLinux"  => {
      :path => "/etc/redhat-release",
      :expected_value => '5.5'
    },
    "SLC" => {
      :path => "/etc/redhat-release",
      :expected_value => '5.7'
    },
  }

  with_fixtures.each do |system, file_data|
    describe "with operatingsystem #{system.inspect}" do
      it "reads the #{file_data[:path].inspect} file" do
        Facter.fact(:operatingsystem).stubs(:value).returns(system)
        Facter::Util::FileRead.expects(:read).with(file_data[:path]).returns(my_fixture_read(system.downcase))
        Facter.fact(:operatingsystemrelease).value.should == file_data[:expected_value]
      end
    end
  end

  it "does not include trailing whitespace on Debian" do
    Facter.fact(:operatingsystem).stubs(:value).returns("Debian")
    Facter::Util::FileRead.stubs(:read).returns("6.0.6\n")
    Facter.fact(:operatingsystemrelease).value.should == "6.0.6"
  end

  it "for VMWareESX it should run the vmware -v command" do
    Facter.fact(:kernel).stubs(:value).returns("VMkernel")
    Facter.fact(:kernelrelease).stubs(:value).returns("4.1.0")
    Facter.fact(:operatingsystem).stubs(:value).returns("VMwareESX")

    Facter::Util::Resolution.stubs(:exec).with('vmware -v').returns('foo')

    Facter.fact(:operatingsystemrelease).value
  end

  it "for Alpine it should use the contents of /etc/alpine-release" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:operatingsystem).stubs(:value).returns("Alpine")

    File.expects(:read).with("/etc/alpine-release").returns("foo")

    Facter.fact(:operatingsystemrelease).value.should == "foo"
  end

  describe "with operatingsystem reported as Solaris" do

    before :each do
      Facter.fact(:kernel).stubs(:value).returns('SunOS')
      Facter.fact(:osfamily).stubs(:value).returns('Solaris')
    end

    {
      'Solaris 8 s28_38shwp2 SPARC'                  => '28',
      'Solaris 8 6/00 s28s_u1wos_08 SPARC'           => '28_u1',
      'Solaris 8 10/00 s28s_u2wos_11b SPARC'         => '28_u2',
      'Solaris 8 1/01 s28s_u3wos_08 SPARC'           => '28_u3',
      'Solaris 8 4/01 s28s_u4wos_08 SPARC'           => '28_u4',
      'Solaris 8 7/01 s28s_u5wos_08 SPARC'           => '28_u5',
      'Solaris 8 10/01 s28s_u6wos_08a SPARC'         => '28_u6',
      'Solaris 8 2/02 s28s_u7wos_08a SPARC'          => '28_u7',
      'Solaris 8 HW 12/02 s28s_hw1wos_06a SPARC'     => '28',
      'Solaris 8 HW 5/03 s28s_hw2wos_06a SPARC'      => '28',
      'Solaris 8 HW 7/03 s28s_hw3wos_05a SPARC'      => '28',
      'Solaris 8 2/04 s28s_hw4wos_05a SPARC'         => '28',
      'Solaris 9 s9_58shwpl3 SPARC'                  => '9',
      'Solaris 9 9/02 s9s_u1wos_08b SPARC'           => '9_u1',
      'Solaris 9 12/02 s9s_u2wos_10 SPARC'           => '9_u2',
      'Solaris 9 4/03 s9s_u3wos_08 SPARC'            => '9_u3',
      'Solaris 9 8/03 s9s_u4wos_08a SPARC'           => '9_u4',
      'Solaris 9 12/03 s9s_u5wos_08b SPARC'          => '9_u5',
      'Solaris 9 4/04 s9s_u6wos_08a SPARC'           => '9_u6',
      'Solaris 9 9/04 s9s_u7wos_09 SPARC'            => '9_u7',
      'Solaris 9 9/05 s9s_u8wos_05 SPARC'            => '9_u8',
      'Solaris 9 9/05 HW s9s_u9wos_06b SPARC'        => '9_u9',
      'Solaris 10 3/05 s10_74L2a SPARC'              => '10',
      'Solaris 10 3/05 HW1 s10s_wos_74L2a SPARC'     => '10',
      'Solaris 10 3/05 HW2 s10s_hw2wos_05 SPARC'     => '10',
      'Solaris 10 1/06 s10s_u1wos_19a SPARC'         => '10_u1',
      'Solaris 10 6/06 s10s_u2wos_09a SPARC'         => '10_u2',
      'Solaris 10 11/06 s10s_u3wos_10 SPARC'         => '10_u3',
      'Solaris 10 8/07 s10s_u4wos_12b SPARC'         => '10_u4',
      'Solaris 10 5/08 s10s_u5wos_10 SPARC'          => '10_u5',
      'Solaris 10 10/08 s10s_u6wos_07b SPARC'        => '10_u6',
      'Solaris 10 5/09 s10s_u7wos_08 SPARC'          => '10_u7',
      'Solaris 10 10/09 s10s_u8wos_08a SPARC'        => '10_u8',
      'Oracle Solaris 10 9/10 s10s_u9wos_14a SPARC'  => '10_u9',
      'Oracle Solaris 10 8/11 s10s_u10wos_17b SPARC' => '10_u10',
      'Solaris 10 3/05 HW1 s10x_wos_74L2a X86'       => '10',
      'Solaris 10 1/06 s10x_u1wos_19a X86'           => '10_u1',
      'Solaris 10 6/06 s10x_u2wos_09a X86'           => '10_u2',
      'Solaris 10 11/06 s10x_u3wos_10 X86'           => '10_u3',
      'Solaris 10 8/07 s10x_u4wos_12b X86'           => '10_u4',
      'Solaris 10 5/08 s10x_u5wos_10 X86'            => '10_u5',
      'Solaris 10 10/08 s10x_u6wos_07b X86'          => '10_u6',
      'Solaris 10 5/09 s10x_u7wos_08 X86'            => '10_u7',
      'Solaris 10 10/09 s10x_u8wos_08a X86'          => '10_u8',
      'Oracle Solaris 10 9/10 s10x_u9wos_14a X86'    => '10_u9',
      'Oracle Solaris 10 8/11 s10x_u10wos_17b X86'   => '10_u10',
    }.each do |fakeinput,expected_output|
      it "should be able to parse a release of #{fakeinput}" do
        Facter::Util::FileRead.stubs(:read).with('/etc/release').returns fakeinput
        Facter.fact(:operatingsystemrelease).value.should == expected_output
      end
    end

    context "malformed /etc/release files" do
      before :each do
        Facter::Util::Resolution.any_instance.stubs(:warn)
      end
      it "should fallback to the kernelrelease fact if /etc/release is empty" do
        Facter::Util::FileRead.stubs(:read).with('/etc/release').
          raises EOFError
        Facter.fact(:operatingsystemrelease).value.
          should == Facter.fact(:kernelrelease).value
      end

      it "should fallback to the kernelrelease fact if /etc/release is not present" do
        Facter::Util::FileRead.stubs(:read).with('/etc/release').
          raises Errno::ENOENT
        Facter.fact(:operatingsystemrelease).value.
          should == Facter.fact(:kernelrelease).value
      end

      it "should fallback to the kernelrelease fact if /etc/release cannot be parsed" do
        Facter::Util::FileRead.stubs(:read).with('/etc/release').
          returns 'some future release string'
        Facter.fact(:operatingsystemrelease).value.
          should == Facter.fact(:kernelrelease).value
      end
    end
  end

  describe "with operatingsystem reported as Windows" do
    require 'facter/util/wmi'
    before do
      Facter.fact(:kernel).stubs(:value).returns("windows")
    end

    {
      ['5.2.3790', 1] => "XP",
      ['6.0.6002', 1] => "Vista",
      ['6.0.6002', 2] => "2008",
      ['6.0.6002', 3] => "2008",
      ['6.1.7601', 1] => "7",
      ['6.1.7601', 2] => "2008 R2",
      ['6.1.7601', 3] => "2008 R2",
      ['6.2.9200', 1] => "8",
      ['6.2.9200', 2] => "2012",
      ['6.2.9200', 3] => "2012",
    }.each do |os_values, expected_output|
      it "should be #{expected_output}  with Version #{os_values[0]}  and ProductType #{os_values[1]}" do
        os = mock('os', :version => os_values[0], :producttype => os_values[1])
        Facter::Util::WMI.expects(:execquery).returns([os])
        Facter.fact(:operatingsystemrelease).value.should == expected_output
      end
    end

    {
      ['5.2.3790', 2, ""]   => "2003",
      ['5.2.3790', 2, "R2"] => "2003 R2",
      ['5.2.3790', 3, ""]   => "2003",
      ['5.2.3790', 3, "R2"] => "2003 R2",
    }.each do |os_values, expected_output|
      it "should be #{expected_output}  with Version #{os_values[0]}  and ProductType #{os_values[1]} and OtherTypeDescription #{os_values[2]}" do
        os = mock('os', :version => os_values[0], :producttype => os_values[1], :othertypedescription => os_values[2])
        Facter::Util::WMI.expects(:execquery).returns([os])
        Facter.fact(:operatingsystemrelease).value.should == expected_output
      end
    end

    context "Unknown Windows version" do
      before :each do
        Facter.fact(:kernelrelease).stubs(:value).returns("X.Y.ZZZZ")
      end

      it "should be kernel version value with unknown values " do
        os = mock('os', :version => "X.Y.ZZZZ")
        Facter::Util::WMI.expects(:execquery).returns([os])
        Facter.fact(:operatingsystemrelease).value.should == "X.Y.ZZZZ"
      end
    end
  end

  context "Ubuntu" do
    let(:lsbrelease) { 'DISTRIB_ID=Ubuntu\nDISTRIB_RELEASE=10.04\nDISTRIB_CODENAME=lucid\nDISTRIB_DESCRIPTION="Ubuntu 10.04.4 LTS"'}
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:operatingsystem).stubs(:value).returns("Ubuntu")
    end

    it "Returns only the major and minor version (not patch version)" do
      Facter::Util::FileRead.stubs(:read).with("/etc/lsb-release").returns(lsbrelease)
      Facter.fact(:operatingsystemrelease).value.should == "10.04"
    end
  end

  context "CumulusLinux" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:operatingsystem).stubs(:value).returns("CumulusLinux")
    end
    it "Returns version from /etc/os-release" do
      Facter::Util::FileRead.stubs(:read).with("/etc/os-release").returns('VERSION_ID=1.5.0')
      Facter.fact(:operatingsystemrelease).value.should == '1.5.0'
    end
  end

end
