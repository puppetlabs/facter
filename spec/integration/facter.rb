#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../spec_helper'

describe Facter do
    before do
        Facter.reset
        Facter.loadfacts
    end

    it "should create a new collection if one does not exist" do
        Facter.reset
        Facter::Collection.expects(:new).returns "coll"
        Facter.collection.should == "coll"
        Facter.reset
    end

    it "should remove the collection when reset" do
        old = Facter.collection
        Facter.reset
        Facter.collection.should_not equal(old)
    end
end
