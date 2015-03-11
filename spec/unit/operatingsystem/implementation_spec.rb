require 'spec_helper'
require 'facter/operatingsystem/implementation'
require 'facter/operatingsystem/base'
require 'facter/operatingsystem/cumuluslinux'
require 'facter/operatingsystem/osreleaselinux'
require 'facter/operatingsystem/linux'
require 'facter/operatingsystem/sunos'
require 'facter/operatingsystem/vmkernel'
require 'facter/operatingsystem/windows'

describe Facter::Operatingsystem do
  it "should return an object of type Linux for linux kernels that are not Cumulus Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter::Util::Operatingsystem.expects(:os_release).at_least_once.returns({'NAME' => 'Some Linux'})
    object = described_class.implementation
    object.should be_a_kind_of(Facter::Operatingsystem::Linux)
  end

  it "should return an object of type Linux for gnu/kfreebsd kernels" do
    Facter.fact(:kernel).stubs(:value).returns("GNU/kFreeBSD")
    Facter::Util::Operatingsystem.expects(:os_release).at_least_once.returns({'NAME' => 'Some Linux'})
    object = described_class.implementation
    object.should be_a_kind_of(Facter::Operatingsystem::Linux)
  end

  it "should identify Cumulus Linux when a Linux kernel is encountered" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter::Util::Operatingsystem.expects(:os_release).at_least_once.returns({'NAME' => 'Cumulus Linux'})
    object = described_class.implementation
    object.should be_a_kind_of(Facter::Operatingsystem::CumulusLinux)
  end

  it "should return an object of type SunOS for SunOS kernels" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    object = described_class.implementation
    object.should be_a_kind_of(Facter::Operatingsystem::SunOS)
  end

  it "should return an object of type VMkernel for VMkernel kernels" do
    Facter.fact(:kernel).stubs(:value).returns("VMkernel")
    object = described_class.implementation
    object.should be_a_kind_of(Facter::Operatingsystem::VMkernel)
  end

  it "should return an object of type Base for other kernels" do
    Facter.fact(:kernel).stubs(:value).returns("Nutmeg")
    object = described_class.implementation
    object.should be_a_kind_of(Facter::Operatingsystem::Base)
  end
end
