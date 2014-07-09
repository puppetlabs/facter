#! /usr/bin/env ruby

require 'spec_helper'

describe "Physical processor count fact" do
  ["linux", "windows", "sunos", "darwin", "openbsd"].each do |kernel|
    it "should return the value of the 'physicalprocessorcount' key of the 'processors' fact" do
      Facter.fact(:kernel).stubs(:value).returns("#{kernel}")
      Facter.fact("processors").stubs(:value).returns({"physicalprocessorcount" => "2", "processorcount" => "4"})
      Facter.fact("physicalprocessorcount").value.should eq "2"
    end
  end
end
