#!user/bin/env rspec 

require 'spec_helper'

describe "Kerenel fact" do
  
  describe "on Windows" do 
    before do 
      Facter::Util::Config.stubs(:is_windows?).returns(true)
    end 
    it "should return the kernel as 'windows'" do 
      Facter.fact(:kernel).value.should == "windows"
    end 
  end 
  
  describe "on everything else" do 
    before do 
     Facter::Util::Resolution.stubs(:exec).with('uname -s').returns("test_kernel")
    end 
    it "should return the kernel using 'uname -s'" do 
      Facter.fact(:kernel).value.should == 'test_kernel'
    end 
  end 
end 

