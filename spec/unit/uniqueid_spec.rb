require 'spec_helper'
require 'facter'

describe "Uniqueid fact" do
  it "should match hostid on Solaris" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter::Util::Resolution.stubs(:exec).with("hostid").returns("Larry")

    Facter.fact(:uniqueid).value.should == "Larry"
  end

  it "should match hostid on Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter::Util::Resolution.stubs(:exec).with("hostid").returns("Curly")

    Facter.fact(:uniqueid).value.should == "Curly"
  end

  it "should match hostid on AIX" do
    Facter.fact(:kernel).stubs(:value).returns("AIX")
    Facter::Util::Resolution.stubs(:exec).with("hostid").returns("Moe")

    Facter.fact(:uniqueid).value.should == "Moe"
  end

  it "should match kern.hostid on FreeBSD" do
    Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
    Facter::Util::POSIX.stubs(:sysctl).with("kern.hostid").returns("Shemp")

    Facter.fact(:uniqueid).value.should == "Shemp"
  end
end
