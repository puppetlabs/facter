#! /usr/bin/env ruby

require 'spec_helper'

describe "Operating System Release fact" do

  before do
    Facter.clear
  end

  after do
    Facter.clear
  end

  test_cases = {
    "CentOS"    => "/etc/redhat-release",
    "RedHat"    => "/etc/redhat-release",
    "Scientific"  => "/etc/redhat-release",
    "Fedora"    => "/etc/fedora-release",
    "MeeGo"     => "/etc/meego-release",
    "OEL"     => "/etc/enterprise-release",
    "oel"     => "/etc/enterprise-release",
    "OVS"     => "/etc/ovs-release",
    "ovs"     => "/etc/ovs-release",
    "OracleLinux" => "/etc/oracle-release",
    "Ascendos"    => "/etc/redhat-release",
  }

  test_cases.each do |system, file|
    describe "with operatingsystem reported as #{system.inspect}" do
      it "should read the #{file.inspect} file" do
        Facter.fact(:operatingsystem).stubs(:value).returns(system)

        File.expects(:open).with(file, "r").at_least(1)

        Facter.fact(:operatingsystemrelease).value
      end
    end
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
      Facter.fact(:operatingsystem).stubs(:value).returns('Solaris')
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
        File.stubs(:open).with('/etc/release','r').returns fakeinput
        Facter.fact(:operatingsystemrelease).value.should == expected_output
      end
    end

    it "should fallback to the kernelrelease fact if /etc/release is empty" do
      File.stubs(:open).with('/etc/release','r').raises EOFError
      Facter::Util::Resolution.any_instance.stubs(:warn) # do not pollute test output
      Facter.fact(:operatingsystemrelease).value.should == Facter.fact(:kernelrelease).value
    end

    it "should fallback to the kernelrelease fact if /etc/release is not present" do
      File.stubs(:open).with('/etc/release','r').raises Errno::ENOENT
      Facter::Util::Resolution.any_instance.stubs(:warn) # do not pollute test output
      Facter.fact(:operatingsystemrelease).value.should == Facter.fact(:kernelrelease).value
    end

    it "should fallback to the kernelrelease fact if /etc/release cannot be parsed" do
      File.stubs(:open).with('/etc/release','r').returns 'some future release string'
      Facter.fact(:operatingsystemrelease).value.should == Facter.fact(:kernelrelease).value
    end

  end
end
