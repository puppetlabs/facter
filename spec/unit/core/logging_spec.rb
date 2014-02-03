require 'spec_helper'
require 'facter/core/logging'

describe Facter::Core::Logging do

  subject { described_class }

  describe "when warning" do
    it "should warn if debugging is enabled" do
      subject.debugging(true)
      Kernel.stubs(:warn)
      Kernel.expects(:warn).with('foo')
      subject.warn('foo')
    end

    it "should not warn if debugging is enabled but nil is passed" do
      subject.debugging(true)
      Kernel.stubs(:warn)
      Kernel.expects(:warn).never
      subject.warn(nil)
    end

    it "should not warn if debugging is enabled but an empyt string is passed" do
      subject.debugging(true)
      Kernel.stubs(:warn)
      Kernel.expects(:warn).never
      subject.warn('')
    end

    it "should not warn if debugging is disabled" do
      subject.debugging(false)
      Kernel.stubs(:warn)
      Kernel.expects(:warn).never
      subject.warn('foo')
    end
  end

  describe "when warning once" do
    it "should only warn once" do
      Kernel.stubs(:warnonce)
      Kernel.expects(:warn).with('foo').once
      subject.warnonce('foo')
      subject.warnonce('foo')
    end

    it "should not warnonce if nil is passed" do
      Kernel.stubs(:warn)
      Kernel.expects(:warnonce).never
      subject.warnonce(nil)
    end

    it "should not warnonce if an empty string is passed" do
      Kernel.stubs(:warn)
      Kernel.expects(:warnonce).never
      subject.warnonce('')
    end
  end

  describe "when setting the debugging mode" do
    it "is enabled when the given value is true" do
      subject.debugging(true)
      expect(subject.debugging?).to be_true
    end

    it "is disabled when the given value is false" do
      subject.debugging(false)
      expect(subject.debugging?).to be_false
    end

    it "is disabled when the given value is nil" do
      subject.debugging(nil)
      expect(subject.debugging?).to be_false
    end
  end

  describe "when setting the timing mode" do
    it "is enabled when the given value is true" do
      subject.timing(true)
      expect(subject.timing?).to be_true
    end

    it "is disabled when the given value is false" do
      subject.timing(false)
      expect(subject.timing?).to be_false
    end

    it "is disabled when the given value is nil" do
      subject.timing(nil)
      expect(subject.timing?).to be_false
    end
  end
end
