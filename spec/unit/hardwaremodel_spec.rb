#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "Hardwaremodel fact" do
  it "should match uname -m by default" do
    Facter.fact(:kernel).stubs(:value).returns("Darwin")
    Facter.fact(:operatingsystem).stubs(:value).returns("Darwin")
    Facter::Core::Execution.stubs(:execute).with("uname -m", anything).returns("Inky")

    Facter.fact(:hardwaremodel).value.should == "Inky"
  end

  describe "on Windows" do
    require 'facter/util/wmi'
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("windows")
      Facter.fact(:operatingsystem).stubs(:value).returns("windows")
    end

    it "should detect i486" do
      cpu = mock('cpu', :Architecture => 0)
      cpu.expects(:Level).returns(4).twice
      Facter::Util::WMI.expects(:execquery).returns([cpu])

      Facter.fact(:hardwaremodel).value.should == "i486"
    end

    it "should detect i686" do
      cpu = mock('cpu', :Architecture => 0, :Level => 6)
      Facter::Util::WMI.expects(:execquery).returns([cpu])

      Facter.fact(:hardwaremodel).value.should == "i686"
    end

    it "should detect x64" do
      cpu = mock('cpu', :Architecture => 9, :AddressWidth => 64, :Level => 6)
      Facter::Util::WMI.expects(:execquery).returns([cpu])

      Facter.fact(:hardwaremodel).value.should == "x64"
    end

    it "(#16948) reports i686 when a 32 bit OS is running on a 64 bit CPU" do
      cpu = mock('cpu', :Architecture => 9, :AddressWidth => 32, :Level => 6)
      Facter::Util::WMI.expects(:execquery).returns([cpu])

      Facter.fact(:hardwaremodel).value.should == "i686"
    end

    it "(#20989) should report i686 when a 32 bit OS is running on a 64 bit CPU and when level is greater than 6 (and not something like i1586)" do
      cpu = mock('cpu', :Architecture => 9, :AddressWidth => 32, :Level => 15)
      Facter::Util::WMI.expects(:execquery).returns([cpu])

      Facter.fact(:hardwaremodel).value.should == "i686"
    end
  end
end
