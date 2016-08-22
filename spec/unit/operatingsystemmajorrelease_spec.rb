#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'facter'

describe "OS Major Release fact" do
    it "should be derived from operatingsystemrelease" do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        Facter.fact(:operatingsystemrelease).stubs(:value).returns("6.3")

        Facter.fact(:operatingsystemmajorrelease).value.should == "6"
    end
end
