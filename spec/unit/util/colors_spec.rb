#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/util/colors'

describe Facter::Util::Colors do
  # Since this module is a mixin, we need to emulate a class that includes it
  let(:class_with_mixin) {
    Class.new do
      include Facter::Util::Colors
    end
  }

  subject { class_with_mixin.new }

  context "#colorize" do
    before :each do
      # Always enable color for these tests
      Facter.expects(:color?).returns(true)
    end

    it "should add red escape chars" do
      subject.colorize(:red, "red").should == "\e[0;31mred\e[0m"
    end

    it "should add green escape chars" do
      subject.colorize(:green, "green").should == "\e[0;32mgreen\e[0m"
    end

    it "should add blue escape chars" do
      subject.colorize(:blue, "blue").should == "\e[0;34mblue\e[0m"
    end

    it "should add reset escape chars" do
      subject.colorize(:reset, "reset").should == "\e[mreset\e[0m"
    end
  end
end
