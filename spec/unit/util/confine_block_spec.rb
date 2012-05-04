#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/util/confine_block'

describe Facter::Util::ConfineBlock do
  it "should accept a block" do
    Facter::Util::ConfineBlock.new(lambda { true })
  end

  context "true? method" do
    it "should return true when block returns true" do
      confine = Facter::Util::ConfineBlock.new(lambda { true })
      confine.true?.should be_true
    end

    it "should return false when block returns false" do
      confine = Facter::Util::ConfineBlock.new(lambda { false })
      confine.true?.should be_false
    end
  end

end
