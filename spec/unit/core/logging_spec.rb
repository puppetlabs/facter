require 'spec_helper'
require 'facter/core/logging'

describe Facter::Core::Logging do

  subject { described_class }

  after(:all) do
    subject.debugging(false)
    subject.timing(false)
    subject.on_message
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

  describe 'without a logging callback' do
    before :each do
      subject.timing(true)
      subject.debugging(true)
      subject.on_message
    end

    it 'calls puts for debug' do
      subject.expects(:puts).with(subject::GREEN + 'foo' + subject::RESET).once
      subject.debug('foo')
    end

    it 'calls puts for debugonce' do
      subject.expects(:puts).with(subject::GREEN + 'foo' + subject::RESET).once
      subject.debugonce('foo')
      subject.debugonce('foo')
    end

    it 'calls Kernel.warn for warn' do
      Kernel.expects(:warn).with('foo').once
      subject.warn('foo')
    end

    it 'calls Kernel.warn for warnonce' do
      Kernel.expects(:warn).with('foo').once
      subject.warnonce('foo')
      subject.warnonce('foo')
    end

    it 'calls $stderr.puts for timing' do
      $stderr.expects(:puts).with(subject::GREEN + 'foo' + subject::RESET).once
      subject.show_time('foo')
    end
  end

  describe 'with a logging callback' do
    before :each do
      subject.debugging(true)
      subject.timing(true)
      subject.on_message
    end

    def log_message(level, message)
      called = false
      subject.on_message do |lvl, msg|
        called = true
        expect(lvl).to eq(level)
        expect(msg).to eq(message)
      end
      case level
      when :debug
        Facter.debug(message)
      when :warn
        Facter.warn(message)
      when :info
        Facter.show_time(message)
      else
        raise 'unexpected logging level'
      end
      subject.on_message
      expect(called).to be_true
    end

    def log_message_once(level, message)
      calls = 0
      subject.on_message do |lvl, msg|
        expect(lvl).to eq(level)
        expect(msg).to eq(message)
        calls += 1
      end
      case level
      when :debug
        Facter.debugonce(message)
        Facter.debugonce(message)
      when :warn
        Facter.warnonce(message)
        Facter.warnonce(message)
      else
        raise 'unexpected logging level'
      end
      expect(calls).to eq(1)
    end

    it 'does not call puts for debug or debugonce' do
      subject.on_message {}
      subject.expects(:puts).never
      subject.debug('debug message')
      subject.debugonce('debug once message')
    end

    it 'passes debug messages to callback' do
      log_message(:debug, 'debug message')
      log_message_once(:debug, 'debug once message')
    end

    it 'does not call Kernel.warn for warn or warnonce' do
      subject.on_message {}
      Kernel.expects(:warn).never
      subject.warn('warn message')
      subject.warnonce('warn once message')
    end

    it 'passes warning messages to callback' do
      log_message(:warn, 'warn message')
      log_message_once(:warn, 'warn once message')
    end

    it 'does not call $stderr.puts for show_time' do
      subject.on_message {}
      $stderr.expects(:puts).never
      subject.show_time('debug message')
    end

    it 'passes info messages to callback' do
      log_message(:info, 'timing message')
    end
  end
end
