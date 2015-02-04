require 'spec_helper'
require 'facter/operatingsystem/linux'

describe Facter::Operatingsystem::Linux do
  subject { described_class.new }

  describe "Operating system fact" do
    describe "On gnu/kfreebsd" do
      it "should return 'GNU/kFreeBSD'" do
        Facter.expects(:value).with(:kernel).returns("GNU/kFreeBSD")
        os = subject.get_operatingsystem
        expect(os).to eq "GNU/kFreeBSD"
      end
    end

    describe "When lsbdistid is available" do
      it "on Ubuntu should use the lsbdistid fact" do
        subject.expects(:get_lsbdistid).returns("Ubuntu")
        os = subject.get_operatingsystem
        expect(os).to eq "Ubuntu"
      end

      it "on LinuxMint should use the lsbdistid fact" do
        subject.expects(:get_lsbdistid).returns("LinuxMint")
        os = subject.get_operatingsystem
        expect(os).to eq "LinuxMint"
      end
    end

    describe "When lsbdistid is not available" do
     {
        "AristaEOS"   => "/etc/Eos-release",
        "Debian"      => "/etc/debian_version",
        "Gentoo"      => "/etc/gentoo-release",
        "Fedora"      => "/etc/fedora-release",
        "Mageia"      => "/etc/mageia-release",
        "Mandriva"    => "/etc/mandriva-release",
        "Mandrake"    => "/etc/mandrake-release",
        "MeeGo"       => "/etc/meego-release",
        "Archlinux"   => "/etc/arch-release",
        "Manjarolinux"=> "/etc/manjaro-release",
        "OracleLinux" => "/etc/oracle-release",
        "OpenWrt"     => "/etc/openwrt_release",
        "Alpine"      => "/etc/alpine-release",
        "VMWareESX"   => "/etc/vmware-release",
        "Bluewhite64" => "/etc/bluewhite64-version",
        "Slamd64"     => "/etc/slamd64-version",
        "Slackware"   => "/etc/slackware-version",
        "Amazon"      => "/etc/system-release"
      }.each_pair do |distribution, releasefile|
        it "should be #{distribution} if #{releasefile} exists" do
          subject.expects(:get_lsbdistid).returns(nil)
          FileTest.expects(:exists?).at_least_once.returns false
          FileTest.expects(:exists?).with(releasefile).returns true
          os = subject.get_operatingsystem
          expect(os).to eq distribution
        end
      end
    end

    describe "on distributions that rely on the contents of /etc/redhat-release" do
      before :each do
        subject.expects(:get_lsbdistid).returns(nil)
      end

      {
        "RedHat"     => "Red Hat Enterprise Linux Server release 6.0 (Santiago)",
        "CentOS"     => "CentOS release 5.6 (Final)",
        "Scientific" => "Scientific Linux release 6.0 (Carbon)",
        "SLC"        => "Scientific Linux CERN SLC release 5.7 (Boron)",
        "Ascendos"   => "Ascendos release 6.0 (Nameless)",
        "CloudLinux" => "CloudLinux Server release 5.5",
        "XenServer"  => "XenServer release 5.6.0-31188p (xenenterprise)",
        "XCP"        => "XCP release 1.6.10-61809c",
      }.each_pair do |operatingsystem, string|
        it "should be #{operatingsystem} based on /etc/redhat-release contents #{string}" do
          FileTest.expects(:exists?).at_least_once.returns false
          FileTest.expects(:exists?).with("/etc/enterprise-release").returns false
          FileTest.expects(:exists?).with("/etc/redhat-release").returns true
          File.expects(:read).with("/etc/redhat-release").at_least_once.returns string
          os = subject.get_operatingsystem
          expect(os).to eq operatingsystem
        end
      end

      it "should be OEL if /etc/ovs-release doesn't exist" do
        FileTest.expects(:exists?).at_least_once.returns false
        FileTest.expects(:exists?).with("/etc/enterprise-release").returns true
        FileTest.expects(:exists?).with("/etc/ovs-release").returns false
        os = subject.get_operatingsystem
        expect(os).to eq "OEL"
      end

      it "should differentiate between Scientific Linux CERN and Scientific Linux" do
        FileTest.expects(:exists?).at_least_once.returns false
        FileTest.expects(:exists?).with("/etc/redhat-release").returns true
        FileTest.expects(:exists?).with("/etc/enterprise-release").returns false
        File.expects(:read).with("/etc/redhat-release").at_least_once.returns("Scientific Linux CERN SLC 5.7 (Boron)")
        os = subject.get_operatingsystem
        expect(os).to eq "SLC"
      end

      it "should default to RedHat" do
        FileTest.expects(:exists?).at_least_once.returns false
        FileTest.expects(:exists?).with("/etc/redhat-release").returns true
        FileTest.expects(:exists?).with("/etc/enterprise-release").returns false
        File.expects(:read).with("/etc/redhat-release").at_least_once.returns("Mystery RedHat")
        os = subject.get_operatingsystem
        expect(os).to eq "RedHat"
      end

      describe "on Oracle variants" do
        it "should be OVS if /etc/ovs-release exists" do
          FileTest.expects(:exists?).at_least_once.returns false
          FileTest.expects(:exists?).with("/etc/enterprise-release").returns true
          FileTest.expects(:exists?).with("/etc/ovs-release").returns true
          os = subject.get_operatingsystem
          expect(os).to eq "OVS"
        end

        it "should be OEL if /etc/ovs-release doesn't exist" do
          FileTest.expects(:exists?).at_least_once.returns false
          FileTest.expects(:exists?).with("/etc/enterprise-release").returns true
          FileTest.expects(:exists?).with("/etc/ovs-release").returns false
          os = subject.get_operatingsystem
          expect(os).to eq "OEL"
        end
      end
    end

    describe "on distributions that rely on the contents of /etc/SuSE-release" do
      before :each do
        subject.expects(:get_lsbdistid).returns(nil)
      end

      {
        "SLES"     => "SUSE LINUX Enterprise Server",
        "SLED"     => "SUSE LINUX Enterprise Desktop",
        "OpenSuSE" => "openSUSE"
      }.each_pair do |operatingsystem, string|
        it "should be #{operatingsystem} based on /etc/SuSE-release contents #{string}" do
          FileTest.expects(:exists?).at_least_once.returns false
          FileTest.expects(:exists?).with("/etc/enterprise-release").returns false
          FileTest.expects(:exists?).with("/etc/redhat-release").returns false
          FileTest.expects(:exists?).with("/etc/SuSE-release").returns true
          File.expects(:read).with("/etc/SuSE-release").at_least_once.returns string
          os = subject.get_operatingsystem
          expect(os).to eq operatingsystem
        end
      end
    end
  end

  describe "Osfamily fact" do
    {
      'Archlinux'    => 'Archlinux',
      "Manjarolinux" => "Archlinux",
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
        subject.expects(:get_operatingsystem).returns(os)
        osfamily = subject.get_osfamily
        expect(osfamily).to eq family
      end
    end

    [
      'MeeGo',
      'VMWareESX',
      'Bluewhite64',
      'Slamd64',
      'Slackware',
      'Alpine',
      'AristaEOS',
    ].each do |os|
      it "should return the kernel fact on operatingsystem #{os}" do
        Facter.expects(:value).with("kernel").returns "Linux"
        subject.expects(:get_operatingsystem).returns(os)
        osfamily = subject.get_osfamily
        expect(osfamily).to eq "Linux"
      end
    end

    it "should return the kernel value on gnu/kfreebsd" do
      Facter.expects(:value).with("kernel").returns "gnu/kfreebsd"
      subject.expects(:get_operatingsystem).returns("Gnu/kfreebsd")
      osfamily = subject.get_osfamily
      expect(osfamily).to eq "gnu/kfreebsd"
    end
  end

  describe "Operatingsystemrelease fact" do
    test_cases = {
      "AristaEOS"   => "/etc/Eos-release",
      "OpenWrt"     => "/etc/openwrt_version",
      "CentOS"      => "/etc/redhat-release",
      "RedHat"      => "/etc/redhat-release",
      "LinuxMint"   => "/etc/linuxmint/info",
      "Scientific"  => "/etc/redhat-release",
      "Fedora"      => "/etc/fedora-release",
      "MeeGo"       => "/etc/meego-release",
      "OEL"         => "/etc/enterprise-release",
      "oel"         => "/etc/enterprise-release",
      "OVS"         => "/etc/ovs-release",
      "ovs"         => "/etc/ovs-release",
      "OracleLinux" => "/etc/oracle-release",
      "Ascendos"    => "/etc/redhat-release",
    }

    test_cases.each do |system, file|
      describe "with operatingsystem reported as #{system}" do
        it "should read #{file}" do
          subject.expects(:get_operatingsystem).at_least_once.returns(system)
          Facter::Util::FileRead.expects(:read).with(file).at_least_once
          release = subject.get_operatingsystemrelease
        end
      end
    end

    it "should not include trailing whitespace on Debian" do
      subject.expects(:get_operatingsystem).returns("Debian")
      Facter::Util::FileRead.expects(:read).returns("6.0.6\n")
      release = subject.get_operatingsystemrelease
      expect(release).to eq "6.0.6"
    end

    it "should run the vmware -v command in VMWareESX" do
      Facter.fact(:kernel).stubs(:value).returns("VMkernel")
      Facter.fact(:kernelrelease).stubs(:value).returns("4.1.0")
      subject.expects(:get_operatingsystem).returns("VMwareESX")
      Facter::Core::Execution.expects(:exec).with('vmware -v').returns("VMware ESX 4.1.0")
      release = subject.get_operatingsystemrelease
      expect(release).to eq "4.1.0"
    end

    it "should use the contents of /etc/alpine-release in Alpine" do
      subject.expects(:get_operatingsystem).returns("Alpine")
      File.expects(:read).with("/etc/alpine-release").returns("foo")
      release = subject.get_operatingsystemrelease
      expect(release).to eq "foo"
    end

    it "should use the contents of /etc/Eos-release in AristaEOS" do
      subject.expects(:get_operatingsystem).returns("AristaEOS")
      File.expects(:read).with("/etc/Eos-release").returns("Arista Networks EOS 4.13.7M")
      release = subject.get_operatingsystemrelease
      expect(release).to eq "4.13.7M"
    end

    it "should fall back to parsing /etc/system-release if lsb facts are not available in Amazon" do
      subject.expects(:get_operatingsystem).returns("Amazon")
      subject.expects(:get_lsbdistrelease).returns(nil)
      Facter::Util::FileRead.expects(:read).with('/etc/system-release').returns("Amazon Linux AMI release 2014.03")
      release = subject.get_operatingsystemrelease
      expect(release).to eq "2014.03"
    end

    it "should fall back to kernelrelease fact for gnu/kfreebsd" do
      Facter.fact(:kernelrelease).stubs(:value).returns("1.2.3")
      subject.expects(:get_operatingsystem).returns("GNU/kFreeBSD")
      release = subject.get_operatingsystemrelease
      expect(release).to eq "1.2.3"
    end

    describe "with operatingsystem reported as Ubuntu" do
      let(:lsbrelease) { 'DISTRIB_ID=Ubuntu\nDISTRIB_RELEASE=10.04\nDISTRIB_CODENAME=lucid\nDISTRIB_DESCRIPTION="Ubuntu 10.04.4 LTS"'}

      it "Returns only the major and minor version (not patch version)" do
        Facter::Util::FileRead.expects(:read).with("/etc/lsb-release").returns(lsbrelease)
        subject.expects(:get_operatingsystem).returns("Ubuntu")
        release = subject.get_operatingsystemrelease
        expect(release).to eq "10.04"
      end
    end
  end

  describe "Operatingsystemmajrelease key" do
    ['Amazon' 'AristaEOS', 'CentOS','CloudLinux','Debian','Fedora','OEL','OracleLinux','OVS','RedHat','Scientific','SLC','CumulusLinux','CoreOS'].each do |operatingsystem|
      describe "on #{operatingsystem} operatingsystems" do
        it "should be derived from operatingsystemrelease" do
          subject.stubs(:get_operatingsystem).returns(operatingsystem)
          subject.expects(:get_operatingsystemrelease).returns("6.3")
          release = subject.get_operatingsystemmajorrelease
          expect(release).to eq "6"
        end
      end
    end

    it "should derive major release properly in Ubuntu" do
      subject.stubs(:get_operatingsystem).returns("Ubuntu")
      subject.expects(:get_operatingsystemrelease).returns("10.04")
      release = subject.get_operatingsystemmajorrelease
      expect(release).to eq "10.04"
    end
  end

  describe "Operatingsystem minor release key" do
    it "should strip off the patch release if appended with a '-'" do
      subject.stubs(:get_operatingsystem).returns("FreeBSD")
      subject.expects(:get_operatingsystemrelease).returns("10.0-RELEASE")
      release = subject.get_operatingsystemminorrelease
      expect(release).to eq "0"
    end
  end

  describe "Lsb facts" do
    let(:raw_lsb_data) { "Distributor ID:\tSomeID\nDescription:\tSome Desc\nRelease:\t14.04\nCodename:\tSomeCodeName\nLSB Version:\t1.2.3" }

    let(:lsb_data) { { "Distributor ID" => "SomeID",
                       "Description"    => "Some Desc",
                       "Release"        => "14.04",
                       "Codename"       => "SomeCodeName",
                       "LSB Version"    => "1.2.3"
                     }
                  }

    let(:lsb_hash) { { "distcodename"      => "SomeCodeName",
                       "distid"            => "SomeID",
                       "distdescription"   => "Some Desc",
                       "distrelease"       => "14.04",
                       "release"           => "1.2.3",
                       "majdistrelease"    => "1",
                       "minordistrelease"  => "2"
                     }
                  }

    describe "collecting LSB data" do
      it "should properly parse the lsb_release command" do
        Facter::Core::Execution.expects(:exec).with('lsb_release -cidvr 2>/dev/null', anything).returns raw_lsb_data
        lsb_hash = subject.collect_lsb_information
        expect(lsb_hash).to eq lsb_data
      end
    end

    describe "lsbdistcodename fact" do
      [ "Linux", "GNU/kFreeBSD"].each do |kernel|
        describe "on #{kernel}" do
          it "returns the codename" do
            subject.expects(:collect_lsb_information).returns lsb_data
            lsbdistcodename = subject.get_lsbdistcodename
            expect(lsbdistcodename).to eq 'SomeCodeName'
          end

          it "returns nil if lsb_release is not installed" do
            subject.expects(:collect_lsb_information).returns nil
            lsbdistcodename = subject.get_lsbdistcodename
            expect(lsbdistcodename).to be_nil
          end
        end
      end

      it "should return the lsbdistcodename in the lsb facts hash" do
        subject.expects(:get_lsb_facts_hash).returns(lsb_hash)
        lsbdistcodename = subject.get_lsb_facts_hash["distcodename"]
        expect(lsbdistcodename).to eq "SomeCodeName"
      end
    end

    describe "lsbdistid fact" do
      [ "Linux", "GNU/kFreeBSD"].each do |kernel|
        describe "on #{kernel}" do
          it "returns the id" do
            subject.expects(:collect_lsb_information).returns lsb_data
            lsbdistid = subject.get_lsbdistid
            expect(lsbdistid).to eq 'SomeID'
          end

          it "returns nil if lsb_release is not installed" do
            subject.expects(:collect_lsb_information).returns nil
            lsbdistid = subject.get_lsbdistid
            expect(lsbdistid).to be_nil
          end
        end
      end

      it "should return the lsbdistid in the lsb facts hash" do
        subject.expects(:get_lsb_facts_hash).returns(lsb_hash)
        lsbdistid = subject.get_lsb_facts_hash["distid"]
        expect(lsbdistid).to eq "SomeID"
      end
    end

    describe "lsbdistdescription fact" do
      [ "Linux", "GNU/kFreeBSD"].each do |kernel|
        describe "on #{kernel}" do
          it "returns the description" do
            subject.expects(:collect_lsb_information).returns lsb_data
            lsbdistdescription = subject.get_lsbdistdescription
            expect(lsbdistdescription).to eq 'Some Desc'
          end

          it "returns nil if lsb_release is not installed" do
            subject.expects(:collect_lsb_information).returns nil
            lsbdistdescription = subject.get_lsbdistdescription
            expect(lsbdistdescription).to be_nil
          end
        end
      end

      it "should return the lsbdistdescription in the lsb facts hash" do
        subject.expects(:get_lsb_facts_hash).returns(lsb_hash)
        lsbdistdescription = subject.get_lsb_facts_hash["distdescription"]
        expect(lsbdistdescription).to eq "Some Desc"
      end
    end

    describe "lsbrelease fact" do
      [ "Linux", "GNU/kFreeBSD"].each do |kernel|
        describe "on #{kernel}" do
          it "returns the LSB release" do
            subject.expects(:collect_lsb_information).returns lsb_data
            lsbrelease = subject.get_lsbrelease
            expect(lsbrelease).to eq '1.2.3'
          end

          it "returns nil if lsb_release is not installed" do
            subject.expects(:collect_lsb_information).returns nil
            lsbrelease = subject.get_lsbrelease
            expect(lsbrelease).to be_nil
          end
        end
      end

      it "should return the lsbrelease in the lsb facts hash" do
        subject.expects(:get_lsb_facts_hash).returns(lsb_hash)
        lsbrelease = subject.get_lsb_facts_hash["release"]
        expect(lsbrelease).to eq '1.2.3'
      end
    end

    describe "lsbdistrelease fact" do
      [ "Linux", "GNU/kFreeBSD"].each do |kernel|
        describe "on #{kernel}" do
          it "should return the dist release" do
            subject.expects(:collect_lsb_information).returns lsb_data
            lsbdistrelease = subject.get_lsbdistrelease
            expect(lsbdistrelease).to eq '14.04'
          end

          it "should return nil if lsb_release is not installed" do
            subject.expects(:collect_lsb_information).returns nil
            lsbdistrelease = subject.get_lsbdistrelease
            expect(lsbdistrelease).to be_nil
          end
        end
      end

      it "should return the lsbdistrelease in the lsb facts hash" do
        subject.expects(:get_lsb_facts_hash).returns(lsb_hash)
        lsbdistrelease = subject.get_lsb_facts_hash["distrelease"]
        expect(lsbdistrelease).to eq '14.04'
      end
    end

    describe "lsbmajdistrelease fact" do
      it "should be derived from lsb_release" do
        subject.expects(:get_operatingsystem).returns("Amazon")
        subject.expects(:get_lsbdistrelease).returns("10.04")
        lsbmajdistrelease = subject.get_lsbmajdistrelease
        expect(lsbmajdistrelease).to eq "10"
      end

      it "should derive correctly in Ubuntu" do
        subject.expects(:get_operatingsystem).returns("Ubuntu")
        subject.expects(:get_lsbdistrelease).returns("10.04")
        lsbmajdistrelease = subject.get_lsbmajdistrelease
        expect(lsbmajdistrelease).to eq "10.04"
      end

      it "should return the lsbmajdistrelease" do
        subject.expects(:get_lsb_facts_hash).returns(lsb_hash)
        lsbmajdistrelease = subject.get_lsb_facts_hash["majdistrelease"]
        expect(lsbmajdistrelease).to eq "1"
      end
    end

    describe "lsbminordistrelease fact" do
      it "should be derived from lsb_release" do
        subject.expects(:get_operatingsystem).returns("Amazon")
        subject.expects(:get_lsbdistrelease).returns("10.04")
        lsbminordistrelease = subject.get_lsbminordistrelease
        expect(lsbminordistrelease).to eq "04"
      end

      it "should derive correctly in Ubuntu" do
        subject.expects(:get_operatingsystem).returns("Ubuntu")
        subject.expects(:get_lsbdistrelease).returns("10.04.02")
        lsbminordistrelease = subject.get_lsbminordistrelease
        expect(lsbminordistrelease).to eq "02"
      end

      it 'should be derived from lsbdistrelease and take Y from version X.Y' do
        subject.expects(:get_operatingsystem).returns("Amazon")
        subject.expects(:get_lsbdistrelease).returns("6.4")
        lsbminordistrelease = subject.get_lsbminordistrelease
        expect(lsbminordistrelease).to eq "4"
      end

      it 'should be derived from lsbdistrelease and take Y from version X.Y.Z' do
        subject.expects(:get_operatingsystem).returns("Amazon")
        subject.expects(:get_lsbdistrelease).returns("6.4.1")
        lsbminordistrelease = subject.get_lsbminordistrelease
        expect(lsbminordistrelease).to eq "4"
      end

      it 'should be derived from lsbdistrelease and take Y from version X.Y.Z where multiple digits exist' do
        subject.expects(:get_operatingsystem).returns("Amazon")
        subject.expects(:get_lsbdistrelease).returns("10.20.30")
        lsbminordistrelease = subject.get_lsbminordistrelease
        expect(lsbminordistrelease).to eq "20"
      end

      it 'should not be present if lsbdistrelease is only X and is missing .Y' do
        subject.expects(:get_operatingsystem).returns("Amazon")
        subject.expects(:get_lsbdistrelease).returns("6")
        lsbminordistrelease = subject.get_lsbminordistrelease
        expect(lsbminordistrelease).to be_nil
      end

      it "should return the lsbmajdistrelease" do
        subject.expects(:get_lsb_facts_hash).returns(lsb_hash)
        lsbminordistrelease = subject.get_lsb_facts_hash["minordistrelease"]
        expect(lsbminordistrelease).to eq "2"
      end
    end
  end
end
