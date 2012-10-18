#! /usr/bin/env ruby

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

  it "should raise an error if a recursion is detected" do
    Facter.clear
    Facter.add(:foo) do
      confine :bar => 'some_value'
    end
    Facter.add(:bar) do
      confine :foo => 'some_value'
    end
    lambda { Facter.value(:foo) }.should raise_error(RuntimeError, /Caught recursion on foo/)
  end

end
