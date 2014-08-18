#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/operatingsystem/base'
require 'facter/operatingsystem/linux'

describe "os" do
  subject { Facter.fact("os") }
  let(:os) { stub 'OS object' }
  let(:lsb_hash) { { "distcodename"    => "trusty",
                     "distid"          => "Ubuntu",
                     "distdescription" => "Ubuntu 14.04 LTS",
                     "distrelease"     => "14.04",
                     "release"         => "14.04",
                     "majdistrelease"  => "14"
                   }
                }

  let(:release_hash) { { "major" => 1,
                         "minor" => 2,
                         "patch" => 3,
                         "full"  => "1.2.3"
                       }
                     }

  describe "in Linux with lsb facts available" do
    before do
      Facter::Operatingsystem::Linux.stubs(:new).returns os
    end

    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      os.expects(:get_operatingsystem).returns("Ubuntu")
      os.expects(:get_osfamily).returns("Debian")
      os.expects(:get_operatingsystemrelease_hash).returns(release_hash)
      os.expects(:has_lsb?).returns(true)
      os.expects(:get_lsb_facts_hash).returns(lsb_hash)
    end

    it "should include a name key with the operatingsystem name" do
      expect(subject.value["name"]).to eq "Ubuntu"
    end

    it "should include a family key with the osfamily name" do
      expect(subject.value["family"]).to eq "Debian"
    end

    it "should include a release key with the OS release" do
      expect(subject.value["release"]["full"]).to eq "1.2.3"
    end

    it "should include a major key with the major release" do
      expect(subject.value["release"]["major"]).to eq 1
    end

    it "should include a minor key with the major release" do
      expect(subject.value["release"]["minor"]).to eq 2
    end

    it "should include a patch key with the patch release" do
      expect(subject.value["release"]["patch"]).to eq 3
    end

    it "should include a distid key with the distid" do
      expect(subject.value["lsb"]["distid"]).to eq "Ubuntu"
    end

    it "should include an distcodename key with the codename" do
      expect(subject.value["lsb"]["distcodename"]).to eq "trusty"
    end

    it "should include an distdescription key with the description" do
      expect(subject.value["lsb"]["distdescription"]).to eq "Ubuntu 14.04 LTS"
    end

    it "should include an release key with the release" do
      expect(subject.value["lsb"]["release"]).to eq "14.04"
    end

    it "should include an distrelease key with the release" do
      expect(subject.value["lsb"]["distrelease"]).to eq "14.04"
    end

    it "should include an majdistrelease key with the major release" do
      expect(subject.value["lsb"]["majdistrelease"]).to eq "14"
    end

  end

  describe "in an OS without lsb facts available" do
    before do
      Facter::Operatingsystem::Base.stubs(:new).returns os
    end

    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Darwin")
      os.expects(:get_operatingsystem).returns("Darwin")
      os.expects(:get_osfamily).returns("Darwin")
      os.expects(:get_operatingsystemrelease_hash).returns(release_hash)
      os.expects(:has_lsb?).returns(false)
    end

    it "should include a name key with the operatingsystem name" do
      expect(subject.value["name"]).to eq "Darwin"
    end

    it "should include a family key with the osfamily name" do
      expect(subject.value["family"]).to eq "Darwin"
    end

    it "should include a release key with the OS release" do
      expect(subject.value["release"]["full"]).to eq "1.2.3"
    end

    it "should include a major with the major release" do
      expect(subject.value["release"]["major"]).to eq 1
    end

    it "should include a minor with the minor release" do
      expect(subject.value["release"]["minor"]).to eq 2
    end

    it "should include a patch with the patch release" do
      expect(subject.value["release"]["patch"]).to eq 3
    end

    it "should not include an lsb key" do
      expect(subject.value["lsb"]).to be_nil
    end
  end
end
