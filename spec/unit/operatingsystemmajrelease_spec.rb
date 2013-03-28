#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'facter'

describe "OS Major Release fact" do
  ['Amazon','CentOS','CloudLinux','Debian','Fedora','OEL','OracleLinux','OVS','RedHat','Scientific','SLC'].each do |operatingsystem|
    context "on #{operatingsystem} operatingsystems" do
      it "should be derived from operatingsystemrelease" do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        Facter.fact(:operatingsystem).stubs(:value).returns(operatingsystem)
        Facter.fact(:operatingsystemrelease).stubs(:value).returns("6.3")
        Facter.fact(:operatingsystemmajrelease).value.should == "6"
      end
    end
  end
end
