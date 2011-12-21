#!/usr/bin/env rspec

require 'spec_helper'

describe Facter do
  before do
    Facter.reset
  end

  after do
    Facter.reset
  end

  it "should create a new collection if one does not exist" do
    Facter.reset
    coll = mock('coll')
    Facter::Util::Collection.stubs(:new).returns coll
    Facter.collection.should equal(coll)
    Facter.reset
  end

  it "should remove the collection when reset" do
    old = Facter.collection
    Facter.reset
    Facter.collection.should_not equal(old)
  end
end
