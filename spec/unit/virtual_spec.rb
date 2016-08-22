#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/virtual'
require 'facter/util/macosx'

describe "Virtual fact" do
  before(:each) do
    Facter::Util::Virtual.stubs(:zone?).returns(false)
    Facter::Util::Virtual.stubs(:openvz?).returns(false)
    Facter::Util::Virtual.stubs(:vserver?).returns(false)
    Facter::Util::Virtual.stubs(:xen?).returns(false)
    Facter::Util::Virtual.stubs(:kvm?).returns(false)
    Facter::Util::Virtual.stubs(:hpvm?).returns(false)
    Facter::Util::Virtual.stubs(:zlinux?).returns(false)
    Facter::Util::Virtual.stubs(:virt_what).returns(nil)
    Facter::Util::Virtual.stubs(:virtualbox?).returns(false)
  end

  it "should be jail on FreeBSD when a jail in kvm" do
    Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
    Facter::Util::Virtual.stubs(:jail?).returns(true)
    Facter::Util::Virtual.stubs(:kvm?).returns(true)
    Facter.fact(:virtual).value.should == "jail"
  end

  it "should be hpvm on HP-UX when in HP-VM" do
    Facter.fact(:kernel).stubs(:value).returns("HP-UX")
    Facter::Util::Virtual.stubs(:hpvm?).returns(true)
    Facter.fact(:virtual).value.should == "hpvm"
  end

  it "should be zlinux on s390x" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:architecture).stubs(:value).returns("s390x")
    Facter::Util::Virtual.stubs(:zlinux?).returns(true)
    Facter.fact(:virtual).value.should == "zlinux"
  end

  describe "on Darwin" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("Darwin")
    end

    it "should be parallels with Parallels vendor id" do
      Facter::Util::Macosx.stubs(:profiler_data).returns({ "spdisplays_vendor-id" => "0x1ab8" })
      Facter.fact(:virtual).value.should == "parallels"
    end

    it "should be parallels with Parallels vendor name" do
      Facter::Util::Macosx.stubs(:profiler_data).returns({ "spdisplays_vendor" => "Parallels" })
      Facter.fact(:virtual).value.should == "parallels"
    end

    it "should be vmware with VMWare vendor id" do
      Facter::Util::Macosx.stubs(:profiler_data).returns({ "spdisplays_vendor-id" => "0x15ad" })
      Facter.fact(:virtual).value.should == "vmware"
    end

    it "should be vmware with VMWare vendor name" do
      Facter::Util::Macosx.stubs(:profiler_data).returns({ "spdisplays_vendor" => "VMWare" })
      Facter.fact(:virtual).value.should == "vmware"
    end
  end

  describe "on Linux" do
    before(:each) do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:operatingsystem).stubs(:value).returns("Linux")

      Facter::Util::Resolution.stubs(:exec).with("vmware -v").returns false

      FileTest.stubs(:exists?).with("/proc/sys/xen").returns false
      FileTest.stubs(:exists?).with("/sys/bus/xen").returns false
      FileTest.stubs(:exists?).with("/proc/xen").returns false
      Facter.fact(:architecture).stubs(:value).returns(true)
    end

    it "should be parallels with Parallels vendor id from lspci 2>/dev/null" do
      Facter::Util::Virtual.stubs(:lspci).returns("01:00.0 VGA compatible controller: Unknown device 1ab8:4005")
      Facter.fact(:virtual).value.should == "parallels"
    end

    it "should be parallels with Parallels vendor name from lspci 2>/dev/null" do
      Facter::Util::Virtual.stubs(:lspci).returns("01:00.0 VGA compatible controller: Parallels Display Adapter")
      Facter.fact(:virtual).value.should == "parallels"
    end

    it "should be vmware with VMware vendor name from lspci 2>/dev/null" do
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns("00:0f.0 VGA compatible controller: VMware Inc [VMware SVGA II] PCI Display Adapter")
      Facter.fact(:virtual).value.should == "vmware"
    end

    it "should be virtualbox with VirtualBox vendor name from lspci 2>/dev/null" do
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns("00:02.0 VGA compatible controller: InnoTek Systemberatung GmbH VirtualBox Graphics Adapter")
      Facter.fact(:virtual).value.should == "virtualbox"
    end

    it "should be vmware with VMWare vendor name from dmidecode" do
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns("On Board Device 1 Information\nType: Video\nStatus: Disabled\nDescription: VMware SVGA II")
      Facter.fact(:virtual).value.should == "vmware"
    end

    it "should be xen0 with xen dom0 files in /proc" do
      Facter.fact(:hardwaremodel).stubs(:value).returns("i386")
      Facter::Util::Virtual.expects(:xen?).returns(true)
      FileTest.expects(:exists?).with("/proc/xen/xsd_kva").returns(true)
      Facter.fact(:virtual).value.should == "xen0"
    end

    it "should be xenu with xen domU files in /proc" do
      Facter.fact(:hardwaremodel).stubs(:value).returns("i386")
      Facter::Util::Virtual.expects(:xen?).returns(true)
      FileTest.expects(:exists?).with("/proc/xen/xsd_kva").returns(false)
      FileTest.expects(:exists?).with("/proc/xen/capabilities").returns(true)
      Facter.fact(:virtual).value.should == "xenu"
    end

    it "should be xenhvm with Xen HVM vendor name from lspci 2>/dev/null" do
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns("00:03.0 Unassigned class [ff80]: XenSource, Inc. Xen Platform Device (rev 01)")
      Facter.fact(:virtual).value.should == "xenhvm"
    end

    it "should be xenhvm with Xen HVM vendor name from dmidecode" do
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns("System Information\nManufacturer: Xen\nProduct Name: HVM domU")
      Facter.fact(:virtual).value.should == "xenhvm"
    end

    it "should be parallels with Parallels vendor name from dmidecode" do
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns("On Board Device Information\nType: Video\nStatus: Disabled\nDescription: Parallels Video Adapter")
      Facter.fact(:virtual).value.should == "parallels"
    end

    it "should be virtualbox with VirtualBox vendor name from dmidecode" do
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns("BIOS Information\nVendor: innotek GmbH\nVersion: VirtualBox\n\nSystem Information\nManufacturer: innotek GmbH\nProduct Name: VirtualBox\nFamily: Virtual Machine")
      Facter.fact(:virtual).value.should == "virtualbox"
    end

    it "should be hyperv with Microsoft vendor name from lspci 2>/dev/null" do
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns("00:08.0 VGA compatible controller: Microsoft Corporation Hyper-V virtual VGA")
      Facter.fact(:virtual).value.should == "hyperv"
    end

    it "should be hyperv with Microsoft vendor name from dmidecode" do
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns("System Information\nManufacturer: Microsoft Corporation\nProduct Name: Virtual Machine")
      Facter.fact(:virtual).value.should == "hyperv"
    end
  end

  describe "on Solaris" do
    before(:each) do
      Facter::Util::Resolution.stubs(:exec).with("vmware -v").returns false
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
    end

    it "should be zone on Solaris when a zone" do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
      Facter::Util::Virtual.stubs(:zone?).returns(true)
      Facter::Util::Virtual.stubs(:vserver?).returns(false)
      Facter::Util::Virtual.stubs(:xen?).returns(false)
      Facter.fact(:virtual).value.should == "zone"
    end


    it "should be vmware with VMWare vendor name from prtdiag" do
      Facter.fact(:hardwaremodel).stubs(:value).returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('prtdiag').returns("System Configuration: VMware, Inc. VMware Virtual Platform")
      Facter.fact(:virtual).value.should == "vmware"
    end

    it "should be parallels with Parallels vendor name from prtdiag" do
      Facter.fact(:hardwaremodel).stubs(:value).returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('prtdiag').returns("System Configuration: Parallels Virtual Platform")
      Facter.fact(:virtual).value.should == "parallels"
    end

    it "should be virtualbox with VirtualBox vendor name from prtdiag" do
      Facter.fact(:hardwaremodel).stubs(:value).returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('prtdiag').returns("System Configuration: innotek GmbH VirtualBox")
      Facter.fact(:virtual).value.should == "virtualbox"
    end
  end

  describe "on OpenBSD" do
    before do
      Facter::Util::Resolution.stubs(:exec).with("vmware -v").returns false
      Facter.fact(:kernel).stubs(:value).returns("OpenBSD")
      Facter.fact(:hardwaremodel).stubs(:value).returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('lspci 2>/dev/null').returns(nil)
      Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns(nil)
    end

    it "should be parallels with Parallels product name from sysctl" do
      Facter::Util::Resolution.stubs(:exec).with('sysctl -n hw.product 2>/dev/null').returns("Parallels Virtual Platform")
      Facter.fact(:virtual).value.should == "parallels"
    end

    it "should be vmware with VMware product name from sysctl" do
      Facter::Util::Resolution.stubs(:exec).with('sysctl -n hw.product 2>/dev/null').returns("VMware Virtual Platform")
      Facter.fact(:virtual).value.should == "vmware"
    end

    it "should be virtualbox with VirtualBox product name from sysctl" do
      Facter::Util::Resolution.stubs(:exec).with('sysctl -n hw.product 2>/dev/null').returns("VirtualBox")
      Facter.fact(:virtual).value.should == "virtualbox"
    end

    it "should be xenhvm with Xen HVM product name from sysctl" do
      Facter::Util::Resolution.stubs(:exec).with('sysctl -n hw.product 2>/dev/null').returns("HVM domU")
      Facter.fact(:virtual).value.should == "xenhvm"
    end
  end

  describe "with the virt-what command available (#8210)" do
    describe "when the output of virt-what disagrees with lower weight facts" do
      virt_what_map = {
        'xen-hvm'  => 'xenhvm',
        'xen-dom0' => 'xen0',
        'xen-domU' => 'xenu',
        'ibm_systemz' => 'zlinux',
      }

      virt_what_map.each do |input,output|
        it "maps #{input} to #{output}" do
          Facter::Util::Virtual.expects(:virt_what).returns(input)
          Facter.value(:virtual).should == output
        end
      end
    end

    describe "arbitrary outputs of virt-what" do
      it "returns the last line output from virt-what" do
        Facter::Util::Virtual.expects(:virt_what).returns("one\ntwo\nthree space\n")
        Facter.value(:virtual).should == "three space"
      end
    end

    describe "when virt-what returns linux_vserver" do
      it "delegates to Facter::Util::Virtual.vserver_type" do
        Facter::Util::Virtual.expects(:virt_what).returns("linux_vserver")
        Facter::Util::Virtual.expects(:vserver_type).returns("fake_vserver_type")
        Facter.value(:virtual).should == "fake_vserver_type"
      end
    end
  end
end

describe "is_virtual fact" do
  it "should be virtual when running on xen" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:virtual).stubs(:value).returns("xenu")
    Facter.fact(:is_virtual).value.should == "true"
  end

  it "should be false when running on xen0" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:virtual).stubs(:value).returns("xen0")
    Facter.fact(:is_virtual).value.should == "false"
  end

  it "should be true when running on xenhvm" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:virtual).stubs(:value).returns("xenhvm")
    Facter.fact(:is_virtual).value.should == "true"
  end

  it "should be false when running on physical" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:virtual).stubs(:value).returns("physical")
    Facter.fact(:is_virtual).value.should == "false"
  end

  it "should be true when running on vmware" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:virtual).stubs(:value).returns("vmware")
    Facter.fact(:is_virtual).value.should == "true"
  end

  it "should be true when running on virtualbox" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:virtual).stubs(:value).returns("virtualbox")
    Facter.fact(:is_virtual).value.should == "true"
  end

  it "should be true when running on openvzve" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:virtual).stubs(:value).returns("openvzve")
    Facter.fact(:is_virtual).value.should == "true"
  end

  it "should be true when running on kvm" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:virtual).stubs(:value).returns("kvm")
    Facter.fact(:is_virtual).value.should == "true"
  end

  it "should be true when running in jail" do
    Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
    Facter.fact(:virtual).stubs(:value).returns("jail")
    Facter.fact(:is_virtual).value.should == "true"
  end

  it "should be true when running in zone" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter.fact(:virtual).stubs(:value).returns("zone")
    Facter.fact(:is_virtual).value.should == "true"
  end

  it "should be true when running on hp-vm" do
    Facter.fact(:kernel).stubs(:value).returns("HP-UX")
    Facter.fact(:virtual).stubs(:value).returns("hpvm")
    Facter.fact(:is_virtual).value.should == "true"
  end

  it "should be true when running on S390" do
    Facter.fact(:architecture).stubs(:value).returns("s390x")
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:virtual).stubs(:value).returns("zlinux")
    Facter.fact(:is_virtual).value.should == "true"
  end

  it "should be true when running on parallels" do
    Facter.fact(:kernel).stubs(:value).returns("Darwin")
    Facter.fact(:virtual).stubs(:value).returns("parallels")
    Facter.fact(:is_virtual).value.should == "true"
  end

  it "should be false on vmware_server" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:virtual).stubs(:value).returns("vmware_server")
    Facter.fact(:is_virtual).value.should == "false"
  end

  it "should be false on openvz host nodes" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:virtual).stubs(:value).returns("openvzhn")
    Facter.fact(:is_virtual).value.should == "false"
  end

  it "should be true when running on hyperv" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:virtual).stubs(:value).returns("hyperv")
    Facter.fact(:is_virtual).value.should == "true"
  end
end
