#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/virtual'
require 'stringio'

describe Facter::Util::Virtual do

  after do
    Facter.clear
  end
  it "should detect openvz" do
    FileTest.stubs(:directory?).with("/proc/vz").returns(true)
    Dir.stubs(:glob).with("/proc/vz/*").returns(['vzquota'])
    Facter::Util::Virtual.should be_openvz
  end

  it "should not detect openvz when /proc/lve/list is present" do
    FileTest.stubs(:file?).with("/proc/lve/list").returns(true)
    Facter::Util::Virtual.should_not be_openvz
  end

  it "should not detect openvz when /proc/vz/ is empty" do
    FileTest.stubs(:file?).with("/proc/lve/list").returns(false)
    FileTest.stubs(:directory?).with("/proc/vz").returns(true)
    Dir.stubs(:glob).with("/proc/vz/*").returns([])
    Facter::Util::Virtual.should_not be_openvz
  end

  it "should identify openvzhn when /proc/self/status has envID of 0" do
    Facter::Util::Virtual.stubs(:openvz?).returns(true)
    FileTest.stubs(:exists?).with("/proc/self/status").returns(true)
    Facter::Core::Execution.stubs(:exec).with('grep "envID" /proc/self/status').returns("envID:  0")
    Facter::Util::Virtual.openvz_type().should == "openvzhn"
  end

  it "should identify openvzve when /proc/self/status has envID of 0" do
    Facter::Util::Virtual.stubs(:openvz?).returns(true)
    FileTest.stubs(:exists?).with('/proc/self/status').returns(true)
    Facter::Core::Execution.stubs(:exec).with('grep "envID" /proc/self/status').returns("envID:  666")
    Facter::Util::Virtual.openvz_type().should == "openvzve"
  end

  it "should not attempt to identify openvz when /proc/self/status has no envID" do
    Facter::Util::Virtual.stubs(:openvz?).returns(true)
    FileTest.stubs(:exists?).with('/proc/self/status').returns(true)
    Facter::Core::Execution.stubs(:exec).with('grep "envID" /proc/self/status').returns("")
    Facter::Util::Virtual.openvz_type().should be_nil
  end

  it "should identify Solaris zones when non-global zone" do
    Facter::Core::Execution.stubs(:exec).with("/sbin/zonename").returns("somezone")
    Facter::Util::Virtual.should be_zone
  end

  it "should not identify Solaris zones when global zone" do
    Facter::Core::Execution.stubs(:exec).with("/sbin/zonename").returns("global")
    Facter::Util::Virtual.should_not be_zone
  end

  it "(#14522) handles the unencoded binary data in /proc/self/status on Solaris" do
    Facter.fact(:osfamily).stubs(:value).returns("Solaris")
    File.stubs(:open).with('/proc/self/status', 'rb').returns(solaris_proc_self_status)
    FileTest.stubs(:exists?).with('/proc/self/status').returns(true)

    Facter::Util::Virtual.vserver?.should eq(false)
  end

  it "should not detect vserver if no self status" do
    FileTest.stubs(:exists?).with("/proc/self/status").returns(false)
    Facter::Util::Virtual.should_not be_vserver
  end

  it "should detect vserver when vxid present in process status" do
    FileTest.stubs(:exists?).with("/proc/self/status").returns(true)
    File.stubs(:open).with("/proc/self/status", "rb").returns(StringIO.new("VxID: 42\n"))
    Facter::Util::Virtual.should be_vserver
  end

  it "should detect vserver when s_context present in process status" do
    FileTest.stubs(:exists?).with("/proc/self/status").returns(true)
    File.stubs(:open).with("/proc/self/status", "rb").returns(StringIO.new("s_context: 42\n"))
    Facter::Util::Virtual.should be_vserver
  end

  it "should not detect vserver when vserver flags not present in process status" do
    FileTest.stubs(:exists?).with("/proc/self/status").returns(true)
    File.stubs(:open).with("/proc/self/status", "rb").returns(StringIO.new("wibble: 42\n"))
    Facter::Util::Virtual.should_not be_vserver
  end

  it "should identify kvm" do
    Facter::Util::Virtual.stubs(:kvm?).returns(true)
    Facter::Core::Execution.stubs(:exec).with('dmidecode 2> /dev/null').returns("something")
    Facter::Util::Virtual.kvm_type().should == "kvm"
  end

  it "should be able to detect RHEV via sysfs on Linux" do
    # Fake files are always hard to stub. :/
    File.stubs(:read).with("/sys/devices/virtual/dmi/id/product_name").
      returns("RHEV Hypervisor")

    Facter::Util::Virtual.should be_rhev
  end

  it "should be able to detect RHEV via sysfs on Linux improperly" do
    # Fake files are always hard to stub. :/
    File.stubs(:read).with("/sys/devices/virtual/dmi/id/product_name").
      returns("something else")

    Facter::Util::Virtual.should_not be_rhev
  end

  it "should be able to detect ovirt via sysfs on Linux" do
    # Fake files are always hard to stub. :/
    File.stubs(:read).with("/sys/devices/virtual/dmi/id/product_name").
      returns("oVirt Node")

    Facter::Util::Virtual.should be_ovirt
  end

  it "should be able to detect ovirt via sysfs on Linux improperly" do
    # Fake files are always hard to stub. :/
    File.stubs(:read).with("/sys/devices/virtual/dmi/id/product_name").
      returns("something else")

    Facter::Util::Virtual.should_not be_ovirt
  end

  it "detects GCE if the DMI product name is Google" do
    File.stubs(:read).with("/sys/devices/virtual/dmi/id/product_name").returns("Google")
    expect(Facter::Util::Virtual.gce?).to be_true
  end

  it "does not detect GCE if the DMI product name is not Google" do
    File.stubs(:read).with("/sys/devices/virtual/dmi/id/product_name").returns('')
    expect(Facter::Util::Virtual.gce?).to be_false
  end

  fixture_path = fixtures('virtual', 'proc_self_status')

  test_cases = [
    [File.join(fixture_path, 'vserver_2_1', 'guest'), true, 'vserver 2.1 guest'],
    [File.join(fixture_path, 'vserver_2_1', 'host'),  true, 'vserver 2.1 host'],
    [File.join(fixture_path, 'vserver_2_3', 'guest'), true, 'vserver 2.3 guest'],
    [File.join(fixture_path, 'vserver_2_3', 'host'),  true, 'vserver 2.3 host']
  ]

  test_cases.each do |status_file, expected, description|
    describe "with /proc/self/status from #{description}" do
      it "should detect vserver as #{expected.inspect}" do
        status = File.read(status_file)
        FileTest.stubs(:exists?).with("/proc/self/status").returns(true)
        File.stubs(:open).with("/proc/self/status", "rb").returns(StringIO.new(status))
        Facter::Util::Virtual.vserver?.should == expected
      end
    end
  end

  it "reads dmi entries as ascii data" do
    entries_file = my_fixture('invalid_unicode_dmi_entries')
    expected_contents = 'Virtual'

    entries = Facter::Util::Virtual.read_sysfs_dmi_entries(entries_file)

    entries.should =~ /#{expected_contents}/
  end

  it "should identify vserver_host when /proc/virtual exists" do
    Facter::Util::Virtual.expects(:vserver?).returns(true)
    FileTest.stubs(:exists?).with("/proc/virtual").returns(true)
    Facter::Util::Virtual.vserver_type().should == "vserver_host"
  end

  it "should identify vserver_type as vserver when /proc/virtual does not exist" do
    Facter::Util::Virtual.expects(:vserver?).returns(true)
    FileTest.stubs(:exists?).with("/proc/virtual").returns(false)
    Facter::Util::Virtual.vserver_type().should == "vserver"
  end

  it "should detect xen when /proc/sys/xen exists" do
    FileTest.expects(:exists?).with("/proc/sys/xen").returns(true)
    Facter::Util::Virtual.should be_xen
  end

  it "should detect xen when /sys/bus/xen exists" do
    FileTest.expects(:exists?).with("/proc/sys/xen").returns(false)
    FileTest.expects(:exists?).with("/sys/bus/xen").returns(true)
    Facter::Util::Virtual.should be_xen
  end

  it "should detect xen when /proc/xen exists" do
    FileTest.expects(:exists?).with("/proc/sys/xen").returns(false)
    FileTest.expects(:exists?).with("/sys/bus/xen").returns(false)
    FileTest.expects(:exists?).with("/proc/xen").returns(true)
    Facter::Util::Virtual.should be_xen
  end

  it "should not detect xen when no sysfs/proc xen directories exist" do
    FileTest.expects(:exists?).with("/proc/sys/xen").returns(false)
    FileTest.expects(:exists?).with("/sys/bus/xen").returns(false)
    FileTest.expects(:exists?).with("/proc/xen").returns(false)
    Facter::Util::Virtual.should_not be_xen
  end

  it "should detect kvm" do
    FileTest.stubs(:exists?).with("/proc/cpuinfo").returns(true)
    File.stubs(:read).with("/proc/cpuinfo").returns("model name : QEMU Virtual CPU version 0.9.1\n")
    Facter::Util::Virtual.should be_kvm
  end

  it "should detect kvm on FreeBSD" do
    FileTest.stubs(:exists?).with("/proc/cpuinfo").returns(false)
    Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
    Facter::Util::POSIX.stubs(:sysctl).with("hw.model").returns("QEMU Virtual CPU version 0.12.4")
    Facter::Util::Virtual.should be_kvm
  end

  it "should detect kvm on OpenBSD" do
    FileTest.stubs(:exists?).with("/proc/cpuinfo").returns(false)
    Facter.fact(:kernel).stubs(:value).returns("OpenBSD")
    Facter::Util::POSIX.stubs(:sysctl).with("hw.model").returns('QEMU Virtual CPU version (cpu64-rhel6) ("AuthenticAMD" 686-class, 512KB L2 cache)')
    Facter::Util::Virtual.should be_kvm
  end

  it "should detect kvm on SunOS" do
    FileTest.stubs(:exists?).with("/proc/cpuinfo").returns(false)
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    FileTest.stubs(:exists?).with("/usr/sbin/prtconf").returns(true)
    Facter::Core::Execution.stubs(:exec).with("/usr/sbin/prtconf -v").returns("Qemu virtual machine")
    Facter::Util::Virtual.should be_kvm
  end

  it "should identify FreeBSD jail when in jail" do
    Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
    Facter::Core::Execution.stubs(:exec).with("/sbin/sysctl -n security.jail.jailed").returns("1")
    Facter::Util::Virtual.should be_jail
  end

  it "should not identify GNU/kFreeBSD jail when not in jail" do
    Facter.fact(:kernel).stubs(:value).returns("GNU/kFreeBSD")
    Facter::Core::Execution.stubs(:exec).with("/bin/sysctl -n security.jail.jailed").returns("0")
    Facter::Util::Virtual.should_not be_jail
  end

  it "should detect hpvm on HP-UX" do
    Facter.fact(:kernel).stubs(:value).returns("HP-UX")
    Facter::Core::Execution.stubs(:exec).with("/usr/bin/getconf MACHINE_MODEL").returns('ia64 hp server Integrity Virtual Machine')
    Facter::Util::Virtual.should be_hpvm
  end

  it "should not detect hpvm on HP-UX when not in hpvm" do
    Facter.fact(:kernel).stubs(:value).returns("HP-UX")
    Facter::Core::Execution.stubs(:exec).with("/usr/bin/getconf MACHINE_MODEL").returns('ia64 hp server rx660')
    Facter::Util::Virtual.should_not be_hpvm
  end

  it "should be able to detect virtualbox via sysfs on Linux" do
    # Fake files are always hard to stub. :/
    File.stubs(:read).with("/sys/devices/virtual/dmi/id/product_name").
      returns("VirtualBox")

    Facter::Util::Virtual.should be_virtualbox
  end

  it "should be able to detect virtualbox via sysfs on Linux improperly" do
    # Fake files are always hard to stub. :/
    File.stubs(:read).with("/sys/devices/virtual/dmi/id/product_name").
      returns("HP-Oracle-Sun-VMWare-funky-town")

    Facter::Util::Virtual.should_not be_virtualbox
  end

  let :solaris_proc_self_status do
    sample_data = my_fixture_read('solaris10_proc_self_status1')
    mockfile = mock('File')
    mockfile.stubs(:read).returns(sample_data)
    mockfile
  end

  shared_examples_for "virt-what" do |kernel, path, null_device, override_location|
    before(:each) do
      Facter.fact(:kernel).stubs(:value).returns(kernel)
      if override_location
        Facter::Core::Execution.expects(:which).with(File.join(Facter::Util::Config.override_binary_dir, "virt-what")).returns(path)
      else
        Facter::Core::Execution.expects(:which).with(File.join(Facter::Util::Config.override_binary_dir, "virt-what")).returns(nil)
        Facter::Core::Execution.expects(:which).with("virt-what").returns(path)
      end
      Facter::Core::Execution.expects(:exec).with("#{path} 2>#{null_device}")
    end

    it "on #{kernel} virt-what is at #{path} and stderr is sent to #{null_device}" do
      Facter::Util::Virtual.virt_what
    end
  end

  context "on linux" do
    describe "override binary dir doesn't exist" do
      it_should_behave_like "virt-what", "linux", "/usr/bin/virt-what", "/dev/null", true
      it_should_behave_like "virt-what", "linux", "/usr/bin/virt-what", "/dev/null", false

      it "should strip out warnings on stdout from virt-what" do
        virt_what_warning = "virt-what: this script must be run as root"
        Facter.fact(:kernel).stubs(:value).returns('linux')
        Facter::Core::Execution.expects(:which).with(File.join(Facter::Util::Config.override_binary_dir, "virt-what")).returns(nil)
        Facter::Core::Execution.expects(:which).with('virt-what').returns "/usr/bin/virt-what"
        Facter::Core::Execution.expects(:exec).with('/usr/bin/virt-what 2>/dev/null').returns virt_what_warning
        Facter::Util::Virtual.virt_what.should_not match /^virt-what: /
      end
    end
  end

  context "on unix" do
    it_should_behave_like "virt-what", "unix", "/usr/bin/virt-what", "/dev/null", true
    it_should_behave_like "virt-what", "unix", "/usr/bin/virt-what", "/dev/null", false
  end

  context "on windows" do
    it_should_behave_like "virt-what", "windows", 'c:\windows\system32\virt-what', "NUL", false
  end

  describe '.lxc?' do
    subject do
      Facter::Util::Virtual.lxc?
    end

    fixture_path = fixtures('virtual', 'proc_1_cgroup')

    context '/proc/1/cgroup has at least one hierarchy rooted in /lxc/' do
      before :each do
        fakepath = Pathname.new(File.join(fixture_path, 'in_a_container'))
        Pathname.stubs(:new).with('/proc/1/cgroup').returns(fakepath)
      end

      it 'is true' do
        subject.should be_true
      end
    end

    context '/proc/1/cgroup has no hierarchies rooted in /lxc/' do
      before :each do
        fakepath = Pathname.new(File.join(fixture_path, 'not_in_a_container'))
        Pathname.stubs(:new).with('/proc/1/cgroup').returns(fakepath)
      end

      it 'is false' do
        subject.should be_false
      end
    end
  end

  describe '.docker?' do
    subject do
      Facter::Util::Virtual.docker?
    end

    fixture_path = fixtures('virtual', 'proc_1_cgroup')

    context '/proc/1/cgroup has at least one hierarchy rooted in /docker/' do
      before :each do
        fakepath = Pathname.new(File.join(fixture_path, 'in_a_docker_container'))
        Pathname.stubs(:new).with('/proc/1/cgroup').returns(fakepath)
      end

      it 'is true' do
        subject.should be_true
      end
    end

    context '/proc/1/cgroup has at least one hierarchy with docker underneath a systemd slice parent' do
      before :each do
        fakepath = Pathname.new(File.join(fixture_path, 'in_a_docker_container_with_systemd_slices'))
        Pathname.stubs(:new).with('/proc/1/cgroup').returns(fakepath)
      end

      it 'is true' do
        subject.should be_true
      end
    end

    context '/proc/1/cgroup has no hierarchies rooted in /docker/' do
      before :each do
        fakepath = Pathname.new(File.join(fixture_path, 'not_in_a_container'))
        Pathname.stubs(:new).with('/proc/1/cgroup').returns(fakepath)
      end

      it 'is false' do
        subject.should be_false
      end
    end
  end
end
