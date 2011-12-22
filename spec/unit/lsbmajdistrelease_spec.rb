#!/usr/bin/env ruby

require 'spec_helper'
require 'facter'

describe "LSB distribution major release fact" do
    it "should be derived from lsb_release" do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        Facter.stubs(:value).with(:lsbdistrelease).returns("10.10")

        Facter.fact(:lsbmajdistrelease).value.should == "10"
    end
end
