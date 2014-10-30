#! /usr/bin/env ruby

require 'spec_helper'

describe "Physical processor count fact" do
  ["linux", "windows", "sunos", "openbsd"].each do |kernel|
    it "should return the value of the 'physicalcount' key of the 'processors' fact on #{kernel}" do
      Facter.fact(:kernel).stubs(:value).returns("#{kernel}")
      Facter.fact("processors").stubs(:value).returns({"physicalcount" => 2, "count" => 4})
      Facter.fact("physicalprocessorcount").value.should eq 2
    end
  end
end
