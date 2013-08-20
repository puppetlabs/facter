#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/architecture'

describe "Architecture fact" do

  it "should default to the hardware model" do
    Facter.fact(:hardwaremodel).stubs(:value).returns("NonSpecialCasedHW")

    Facter.fact(:architecture).value.should == "NonSpecialCasedHW"
  end

  os_archs = Hash.new
  os_archs = {
    ["Debian","x86_64"] => "amd64",
    ["Gentoo","x86_64"] => "amd64",
    ["GNU/kFreeBSD","x86_64"] => "amd64",
    ["Ubuntu","x86_64"] => "amd64",
    ["Gentoo","i386"] => "x86",
    ["Gentoo","i486"] => "x86",
    ["Gentoo","i586"] => "x86",
    ["Gentoo","i686"] => "x86",
    ["Gentoo","pentium"] => "x86",
    ["windows","i386"] => "x86",
    ["windows","i686"] => "x86",
    ["windows","x64"] => "x64",
  }
  generic_archs = Hash.new
  generic_archs = {
    "i386" => "i386",
    "i486" => "i386",
    "i586" => "i386",
    "i686" => "i386",
    "pentium" => "i386",
  }

  os_archs.each do |pair, result|
    it "should be #{result} if os is #{pair[0]} and hardwaremodel is #{pair[1]}" do
     Facter.fact(:operatingsystem).stubs(:value).returns(pair[0])
     Facter.fact(:hardwaremodel).stubs(:value).returns(pair[1])

     Facter.fact(:architecture).value.should == result
    end
  end

  generic_archs.each do |hw, result|
    it "should be #{result} if hardwaremodel is #{hw}" do
     Facter.fact(:hardwaremodel).stubs(:value).returns(hw)
     Facter.fact(:operatingsystem).stubs(:value).returns("NonSpecialCasedOS")

     Facter.fact(:architecture).value.should == result
    end
  end

  it "(#16081) should be PowerPC_POWER7 if os is AIX" do
    Facter.fact(:kernel).stubs(:value).returns("AIX")
    Facter::Util::Architecture.stubs(:lsattr).returns("type PowerPC_POWER7 Processor type False")
    Facter.fact(:hardwaremodel).stubs(:value).returns("IBM,8233-E8B")
    Facter.fact(:architecture).value.should == "PowerPC_POWER7"
  end

end
