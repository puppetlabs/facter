#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "Kernel major version fact" do
  
  before do 
    Facter.fact(:kernelversion).stubs(:value).returns("12.34.56")
  end 
  
  it "should return the kernel major release using the kernel release" do 
    Facter.fact(:kernelmajversion).value.should == "12.34"
  end 
end 



