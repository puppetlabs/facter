#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "Hardwaremodel fact" do
  it "should match uname -m by default" do
    Facter.fact(:kernel).stubs(:value).returns("Darwin")
    Facter::Util::Resolution.stubs(:exec).with("uname -m").returns("Inky")

    Facter.fact(:hardwaremodel).value.should == "Inky"
  end

  describe "on Windows" do
    require 'facter/util/wmi'
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("windows")
    end

    it "should detect i686" do
      cpu = mock('cpu', :Architecture => 0, :Level => 6)
      Facter::Util::WMI.expects(:execquery).returns([cpu])

      Facter.fact(:hardwaremodel).value.should == "i686"
    end

    it "should detect x64" do
      cpu = mock('cpu', :Architecture => 9)
      Facter::Util::WMI.expects(:execquery).returns([cpu])

      Facter.fact(:hardwaremodel).value.should == "x64"
    end
  end
end
