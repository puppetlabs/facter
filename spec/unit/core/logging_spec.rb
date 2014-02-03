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

    it "should warn for any given element for an array if debugging is enabled" do
      subject.debugging(true)
      Kernel.stubs(:warn)
      Kernel.expects(:warn).with('foo')
      Kernel.expects(:warn).with('bar')
      subject.warn( ['foo','bar'])
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

  describe "when setting debugging mode" do
    it "should have debugging enabled using 1" do
      subject.debugging(1)
      subject.should be_debugging
    end
    it "should have debugging enabled using true" do
      subject.debugging(true)
      subject.should be_debugging
    end
    it "should have debugging enabled using any string except off" do
      subject.debugging('aaaaa')
      subject.should be_debugging
    end
    it "should have debugging disabled using 0" do
      subject.debugging(0)
      subject.should_not be_debugging
    end
    it "should have debugging disabled using false" do
      subject.debugging(false)
      subject.should_not be_debugging
    end
    it "should have debugging disabled using the string 'off'" do
      subject.debugging('off')
      subject.should_not be_debugging
    end
  end

  describe "when setting timing mode" do
    it "should have timing enabled using 1" do
      subject.timing(1)
      subject.should be_timing
    end
    it "should have timing enabled using true" do
      subject.timing(true)
      subject.should be_timing
    end
    it "should have timing disabled using 0" do
      subject.timing(0)
      subject.should_not be_timing
    end
    it "should have timing disabled using false" do
      subject.timing(false)
      subject.should_not be_timing
    end
  end

end
