#! /usr/bin/env ruby

require 'spec_helper'

describe "Kernel fact" do
  include FacterSpec::ConfigHelper

  describe "on Windows" do
    it "should return the kernel as 'windows'" do
      given_a_configuration_of(:is_windows => true, :data_dir => "data_dir")

      Facter.fact(:kernel).value.should == "windows"
    end
  end

  describe "on everything else" do
    it "should return the kernel using 'uname -s'" do
      given_a_configuration_of(:is_windows => false)
      Facter::Core::Execution.stubs(:exec).with('uname -s').returns("test_kernel")

      Facter.fact(:kernel).value.should == 'test_kernel'
    end
  end
end
