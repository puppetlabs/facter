require File.dirname(__FILE__) + '/../spec_helper'

require 'facter'
require 'facter/util/virtual'

describe "Virtual fact" do

    after do
        Facter.clear
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

end

describe "is_virtual fact" do

    after do
        Facter.clear
    end

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

    it "should be true when running on vmware" do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        Facter.fact(:virtual).stubs(:value).returns("vmware")
        Facter.fact(:is_virtual).value.should == "true"
    end

    it "should be true when running on openvz" do
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

end
