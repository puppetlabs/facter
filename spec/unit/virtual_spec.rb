require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'facter'
require 'facter/util/virtual'
require 'facter/util/macosx'

describe "Virtual fact" do
  before do
      Facter::Util::Virtual.stubs(:zone?).returns(false)
      Facter::Util::Virtual.stubs(:openvz?).returns(false)
      Facter::Util::Virtual.stubs(:vserver?).returns(false)
      Facter::Util::Virtual.stubs(:xen?).returns(false)
      Facter::Util::Virtual.stubs(:kvm?).returns(false)
      Facter::Util::Virtual.stubs(:hpvm?).returns(false)
      Facter::Util::Virtual.stubs(:zlinux?).returns(false)
  end

  it "should be zone on Solaris when a zone" do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
      Facter::Util::Virtual.stubs(:zone?).returns(true)
      Facter::Util::Virtual.stubs(:vserver?).returns(false)
      Facter::Util::Virtual.stubs(:xen?).returns(false)
      Facter.fact(:virtual).value.should == "zone"
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
      it "should be parallels with Parallels vendor id" do
          Facter.fact(:kernel).stubs(:value).returns("Darwin")
          Facter::Util::Macosx.stubs(:profiler_data).returns({ "spdisplays_vendor-id" => "0x1ab8" })
          Facter.fact(:virtual).value.should == "parallels"
      end

      it "should be parallels with Parallels vendor name" do
          Facter.fact(:kernel).stubs(:value).returns("Darwin")
          Facter::Util::Macosx.stubs(:profiler_data).returns({ "spdisplays_vendor" => "Parallels" })
          Facter.fact(:virtual).value.should == "parallels"
      end

      it "should be vmware with VMWare vendor id" do
          Facter.fact(:kernel).stubs(:value).returns("Darwin")
          Facter::Util::Macosx.stubs(:profiler_data).returns({ "spdisplays_vendor-id" => "0x15ad" })
          Facter.fact(:virtual).value.should == "vmware"
      end

      it "should be vmware with VMWare vendor name" do
          Facter.fact(:kernel).stubs(:value).returns("Darwin")
          Facter::Util::Macosx.stubs(:profiler_data).returns({ "spdisplays_vendor" => "VMWare" })
          Facter.fact(:virtual).value.should == "vmware"
      end
  end

  describe "on Linux" do

      before do
        Facter::Util::Resolution.expects(:exec).with("vmware -v").returns false
        Facter.fact(:operatingsystem).stubs(:value).returns(true)
        Facter.fact(:architecture).stubs(:value).returns(true)
      end

      it "should be parallels with Parallels vendor id from lspci" do
          Facter.fact(:kernel).stubs(:value).returns("Linux")
          Facter::Util::Resolution.stubs(:exec).with('lspci').returns("01:00.0 VGA compatible controller: Unknown device 1ab8:4005")
          Facter.fact(:virtual).value.should == "parallels"
      end

      it "should be parallels with Parallels vendor name from lspci" do
          Facter.fact(:kernel).stubs(:value).returns("Linux")
          Facter::Util::Resolution.stubs(:exec).with('lspci').returns("01:00.0 VGA compatible controller: Parallels Display Adapter")
          Facter.fact(:virtual).value.should == "parallels"
      end

      it "should be vmware with VMware vendor name from lspci" do
          Facter.fact(:kernel).stubs(:value).returns("Linux")
          Facter::Util::Resolution.stubs(:exec).with('lspci').returns("00:0f.0 VGA compatible controller: VMware Inc [VMware SVGA II] PCI Display Adapter")
          Facter.fact(:virtual).value.should == "vmware"
      end

      it "should be virtualbox with VirtualBox vendor name from lspci" do
          Facter.fact(:kernel).stubs(:value).returns("Linux")
          Facter::Util::Resolution.stubs(:exec).with('lspci').returns("00:02.0 VGA compatible controller: InnoTek Systemberatung GmbH VirtualBox Graphics Adapter")
          Facter.fact(:virtual).value.should == "virtualbox"
      end

      it "should be vmware with VMWare vendor name from dmidecode" do
          Facter.fact(:kernel).stubs(:value).returns("Linux")
          Facter::Util::Resolution.stubs(:exec).with('lspci').returns(nil)
          Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns("On Board Device 1 Information\nType: Video\nStatus: Disabled\nDescription: VMware SVGA II")
          Facter.fact(:virtual).value.should == "vmware"
      end

      it "should be xenhvm with Xen HVM vendor name from lspci" do
          Facter.fact(:kernel).stubs(:value).returns("Linux")
          Facter::Util::Resolution.stubs(:exec).with('lspci').returns("00:03.0 Unassigned class [ff80]: XenSource, Inc. Xen Platform Device (rev 01)")
          Facter.fact(:virtual).value.should == "xenhvm"
      end

      it "should be xenhvm with Xen HVM vendor name from dmidecode" do
          Facter.fact(:kernel).stubs(:value).returns("Linux")
          Facter::Util::Resolution.stubs(:exec).with('lspci').returns(nil)
          Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns("System Information\nManufacturer: Xen\nProduct Name: HVM domU")
          Facter.fact(:virtual).value.should == "xenhvm"
      end

      it "should be parallels with Parallels vendor name from dmidecode" do
          Facter.fact(:kernel).stubs(:value).returns("Linux")
          Facter::Util::Resolution.stubs(:exec).with('lspci').returns(nil)
          Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns("On Board Device Information\nType: Video\nStatus: Disabled\nDescription: Parallels Video Adapter")
          Facter.fact(:virtual).value.should == "parallels"
      end

      it "should be virtualbox with VirtualBox vendor name from dmidecode" do
          Facter.fact(:kernel).stubs(:value).returns("Linux")
          Facter::Util::Resolution.stubs(:exec).with('lspci').returns(nil)
          Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns("BIOS Information\nVendor: innotek GmbH\nVersion: VirtualBox\n\nSystem Information\nManufacturer: innotek GmbH\nProduct Name: VirtualBox\nFamily: Virtual Machine")
          Facter.fact(:virtual).value.should == "virtualbox"
      end

  end
  describe "on Solaris" do
      before(:each) do
          Facter::Util::Resolution.expects(:exec).with("vmware -v").returns false
      end

      it "should be vmware with VMWare vendor name from prtdiag" do
          Facter.fact(:kernel).stubs(:value).returns("SunOS")
          Facter::Util::Resolution.stubs(:exec).with('lspci').returns(nil)
          Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns(nil)
          Facter::Util::Resolution.stubs(:exec).with('prtdiag').returns("System Configuration: VMware, Inc. VMware Virtual Platform")
          Facter.fact(:virtual).value.should == "vmware"
      end

      it "should be parallels with Parallels vendor name from prtdiag" do
          Facter.fact(:kernel).stubs(:value).returns("SunOS")
          Facter::Util::Resolution.stubs(:exec).with('lspci').returns(nil)
          Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns(nil)
          Facter::Util::Resolution.stubs(:exec).with('prtdiag').returns("System Configuration: Parallels Virtual Platform")
          Facter.fact(:virtual).value.should == "parallels"
      end

      it "should be virtualbox with VirtualBox vendor name from prtdiag" do
          Facter.fact(:kernel).stubs(:value).returns("SunOS")
          Facter::Util::Resolution.stubs(:exec).with('lspci').returns(nil)
          Facter::Util::Resolution.stubs(:exec).with('dmidecode').returns(nil)
          Facter::Util::Resolution.stubs(:exec).with('prtdiag').returns("System Configuration: innotek GmbH VirtualBox")
          Facter.fact(:virtual).value.should == "virtualbox"
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
end
