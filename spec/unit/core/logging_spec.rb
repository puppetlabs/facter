require 'spec_helper'
require 'facter/core/logging'

describe Facter::Core::Logging do

  subject { described_class }

  after(:all) do
    subject.debugging(false)
    subject.timing(false)
  end

  describe "emitting debug messages" do
    it "doesn't log a message when debugging is disabled" do
      subject.debugging(false)
      subject.expects(:puts).never
      subject.debug("foo")
    end

    describe "and debugging is enabled" do
      before { subject.debugging(true) }
      it "emits a warning when called with nil" do
        subject.expects(:warn).with { |msg| expect(msg).to match /invalid message nil:NilClass/ }
        subject.debug(nil)
      end

      it "emits a warning when called with an empty string" do
        subject.expects(:warn).with { |msg| expect(msg).to match /invalid message "":String/ }
        subject.debug("")
      end

      it "prints the message when logging is enabled" do
        subject.expects(:puts).with { |msg| expect(msg).to match /foo/ }
        subject.debug("foo")
      end
    end
  end

  describe "when warning" do
    it "emits a warning when given a string" do
      subject.debugging(true)
      Kernel.expects(:warn).with('foo')
      subject.warn('foo')
    end

    it "emits a warning regardless of log level" do
      subject.debugging(false)
      Kernel.expects(:warn).with "foo"
      subject.warn "foo"
    end

    it "emits a warning if nil is passed" do
      Kernel.expects(:warn).with { |msg| expect(msg).to match /invalid message nil:NilClass/ }
      subject.warn(nil)
    end

    it "emits a warning if an empty string is passed" do
      Kernel.expects(:warn).with { |msg| expect(msg).to match /invalid message "":String/ }
      subject.warn('')
    end
  end

  describe "when warning once" do
    it "only logs a given warning string once" do
      subject.expects(:warn).with('foo').once
      subject.warnonce('foo')
      subject.warnonce('foo')
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
