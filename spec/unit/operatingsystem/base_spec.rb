require 'spec_helper'
require 'facter/operatingsystem/base'

describe Facter::Operatingsystem::Base do
  subject { described_class.new }

  before :each do
    Facter.fact(:kernel).stubs(:value).returns("Nutmeg")
  end

  describe "Operating system fact" do
    it "should default to the kernel name" do
      os = subject.get_operatingsystem
      expect(os).to eq "Nutmeg"
    end
  end

  describe "Osfamily fact" do
    it "should default to the kernel name" do
      osfamily = subject.get_osfamily
      expect(osfamily).to eq "Nutmeg"
    end
  end

  describe "Operatingsystemrelease fact" do
    it "should return the kernel fact by default" do
      Facter.fact(:kernelrelease).stubs(:value).returns("1.2.3")
      operatingsystemrelease = subject.get_operatingsystemrelease
      expect(operatingsystemrelease).to eq "1.2.3"
    end
  end

  describe "Operatingsystemmajrelease fact" do
    it "should base major release on release fact if available" do
      subject.expects(:get_operatingsystemrelease).returns("1.2.3")
      operatingsystemmajrelease = subject.get_operatingsystemmajorrelease
      expect(operatingsystemmajrelease).to eq "1"
    end

    it "should return nil if release fact not available" do
      subject.expects(:get_operatingsystemrelease).returns(nil)
      operatingsystemmajrelease = subject.get_operatingsystemmajorrelease
      expect(operatingsystemmajrelease).to be_nil
    end
  end

  describe "Operatingsystemminorrelease" do
    it "should base minor release on release fact if available" do
      subject.expects(:get_operatingsystemrelease).returns("1.2.3")
      operatingsystemminorrelease = subject.get_operatingsystemminorrelease
      expect(operatingsystemminorrelease).to eq "2"
    end

    it "should strip off the patch release if appended with a '-'" do
      subject.stubs(:get_operatingsystem).returns("FreeBSD")
      subject.expects(:get_operatingsystemrelease).returns("10.0-RELEASE")
      release = subject.get_operatingsystemminorrelease
      expect(release).to eq "0"
    end

    it "should return nil if release fact not available" do
      subject.expects(:get_operatingsystemrelease).returns(nil)
      operatingsystemmajrelease = subject.get_operatingsystemminorrelease
      expect(operatingsystemmajrelease).to be_nil
    end
  end


  describe "Operatingsystemrelease hash" do
    it "should return a hash of release values" do
      subject.expects(:get_operatingsystemrelease).at_least_once.returns("1.2.3")
      release_hash = subject.get_operatingsystemrelease_hash
      expect(release_hash).to eq({"major" => "1", "minor" => "2", "full" => "1.2.3" })
    end
  end
end
