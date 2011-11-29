#!usr/bin/env ruby
#Test for process ID fact. 
#Author: Shubhra Sinha Varma

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "process id fact" do
   it "should use the pid command" do
         Facter.fact(:pid).value.should == Process.pid
    end
end

