#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "Hardwareisa fact" do
  it "should match uname -p on Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter::Core::Execution.stubs(:exec).with("uname -p").returns("Inky")

    Facter.fact(:hardwareisa).value.should == "Inky"
  end

  it "should match uname -p on Darwin" do
    Facter.fact(:kernel).stubs(:value).returns("Darwin")
    Facter::Core::Execution.stubs(:exec).with("uname -p").returns("Blinky")

    Facter.fact(:hardwareisa).value.should == "Blinky"
  end

  it "should match uname -p on SunOS" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter::Core::Execution.stubs(:exec).with("uname -p").returns("Pinky")

    Facter.fact(:hardwareisa).value.should == "Pinky"
  end

  it "should match uname -p on FreeBSD" do
    Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
    Facter::Core::Execution.stubs(:exec).with("uname -p").returns("Clyde")

    Facter.fact(:hardwareisa).value.should == "Clyde"
  end

  it "should match uname -m on HP-UX" do
    Facter.fact(:kernel).stubs(:value).returns("HP-UX")
    Facter::Core::Execution.stubs(:exec).with("uname -m").returns("Pac-Man")

    Facter.fact(:hardwareisa).value.should == "Pac-Man"
  end
end
