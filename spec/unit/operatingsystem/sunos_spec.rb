require 'spec_helper'
require 'facter/operatingsystem/sunos'

describe Facter::Operatingsystem::SunOS do
  subject { described_class.new }

  describe "Operating system fact" do
    it "should be Nexenta if /etc/debian_version is present" do
      FileTest.expects(:exists?).with("/etc/debian_version").returns true
      os = subject.get_operatingsystem
      expect(os).to eq "Nexenta"
    end

    it "should be Solaris if /etc/debian_version is missing and uname -v failed to match" do
      FileTest.expects(:exists?).with("/etc/debian_version").returns false
      os = subject.get_operatingsystem
      expect(os).to eq "Solaris"
    end

    {
      "SmartOS"     => "joyent_20120629T002039Z",
      "OmniOS"      => "omnios-dda4bb3",
      "OpenIndiana" => "oi_151a",
    }.each_pair do |distribution, string|
      it "should be #{distribution} if uname -v is '#{string}'" do
        Facter::Core::Execution.expects(:exec).with('uname -v').returns(string)
        os = subject.get_operatingsystem
        expect(os).to eq distribution
      end
    end
  end

  describe "Osfamily fact" do
    it "should return Solaris" do
      osfamily = subject.get_osfamily
      expect(osfamily).to eq "Solaris"
    end
  end

  describe "Operatingsystemrelease fact" do
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
      'Oracle Solaris 11 11/11 X86'                  => '11 11/11',
      'Oracle Solaris 11.1 SPARC'                    => '11.1'
    }.each do |fakeinput, expected_output|
      it "should be able to parse a release of #{fakeinput}" do
        Facter::Util::FileRead.expects(:read).with("/etc/release").returns fakeinput
        release = subject.get_operatingsystemrelease
        expect(release).to eq expected_output
      end
    end

    context "malformed /etc/release files" do
      it "should fallback to the kernelrelease fact if /etc/release is empty" do
        Facter::Util::FileRead.expects(:read).with('/etc/release').returns("")
        release = subject.get_operatingsystemrelease
        expect(release).to eq Facter.fact(:kernelrelease).value
      end

      it "should fallback to the kernelrelease fact if /etc/release is not present" do
        Facter::Util::FileRead.expects(:read).with('/etc/release').returns false
        release = subject.get_operatingsystemrelease
        expect(release).to eq Facter.fact(:kernelrelease).value
      end

      it "should fallback to the kernelrelease fact if /etc/release cannot be parsed" do
        Facter::Util::FileRead.expects(:read).with('/etc/release').returns 'some future release string'
        release = subject.get_operatingsystemrelease
        expect(release).to eq Facter.fact(:kernelrelease).value
      end
    end
  end

  describe "Operatingsystemmajrelease fact" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
      subject.expects(:get_operatingsystem).returns("Solaris")
    end

    it "should correctly derive from operatingsystemrelease on solaris 10" do
      subject.expects(:get_operatingsystemrelease).returns("10_u8")
      release = subject.get_operatingsystemmajorrelease
      expect(release).to eq "10"
    end

    it "should correctly derive from operatingsystemrelease on solaris 11 (old version scheme)" do
      subject.expects(:get_operatingsystemrelease).returns("11 11/11")
      release = subject.get_operatingsystemmajorrelease
      expect(release).to eq "11"
    end

    it "should correctly derive from operatingsystemrelease on solaris 11 (new version scheme)" do
      subject.expects(:get_operatingsystemrelease).returns("11.1")
      release = subject.get_operatingsystemmajorrelease
      expect(release).to eq "11"
    end
  end
end
