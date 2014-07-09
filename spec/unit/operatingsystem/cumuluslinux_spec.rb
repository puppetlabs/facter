require 'spec_helper'
require 'facter/operatingsystem/cumuluslinux'

describe Facter::Operatingsystem::CumulusLinux do
  subject { described_class.new }

  before :all do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
  end

  describe "Operating system fact" do
    it "should identify Cumulus Linux" do
      os = subject.get_operatingsystem
      expect(os).to eq "CumulusLinux"
    end
  end

  describe "Osfamily fact" do
    it "should return Debian" do
      osfamily = subject.get_osfamily
      expect(osfamily).to eq "Debian"
    end
  end

  describe "Operatingsystemrelease fact" do
    it "uses '/etc/os-release" do
      Facter::Util::Operatingsystem.expects(:os_release).returns({"VERSION_ID" => "1.5.0"})
      release = subject.get_operatingsystemrelease
      expect(release).to eq "1.5.0"
    end
  end

  describe "Operatingsystemmajrelease fact" do
    it "should return the majrelease value based on its operatingsystemrelease" do
      subject.expects(:get_operatingsystemrelease).returns("1.5.0")
      release = subject.get_operatingsystemmajrelease
      expect(release).to eq "1"
    end
  end
end
