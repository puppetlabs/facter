# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe LegacyFacter::Core::Logging do
  subject(:logging) { LegacyFacter::Core::Logging }

  after do
    logging.debugging(false)
    logging.timing(false)
    logging.on_message
  end

  describe 'emitting debug messages' do
    it "doesn't log a message when debugging is disabled" do
      logging.debugging(false)
      expect(logging).not_to receive(:puts)
      logging.debug('foo')
    end

    describe 'and debugging is enabled' do
      before { logging.debugging(true) }

      it 'emits a warning when called with nil' do
        expect(logging).to receive(:warn).with(/invalid message nil:NilClass/)
        logging.debug(nil)
      end

      it 'emits a warning when called with an empty string' do
        expect(logging).to receive(:warn).with(/invalid message "":String/)
        logging.debug('')
      end

      it 'prints the message when logging is enabled' do
        expect(logging).to receive(:puts).with(/foo/)
        logging.debug('foo')
      end
    end
  end

  describe 'when warning' do
    it 'emits a warning when given a string' do
      logging.debugging(true)
      expect(Kernel).to receive(:warn).with('foo')
      logging.warn('foo')
    end

    it 'emits a warning regardless of log level' do
      logging.debugging(false)
      expect(Kernel).to receive(:warn).with('foo')
      logging.warn 'foo'
    end

    it 'emits a warning if nil is passed' do
      expect(Kernel).to receive(:warn).with(/invalid message nil:NilClass/)
      logging.warn(nil)
    end

    it 'emits a warning if an empty string is passed' do
      expect(Kernel).to receive(:warn).with(/invalid message "":String/)
      logging.warn('')
    end
  end

  describe 'when warning once' do
    it 'only logs a given warning string once' do
      expect(logging).to receive(:warn).with('foo').once
      logging.warnonce('foo')
      logging.warnonce('foo')
    end
  end

  describe 'when setting the debugging mode' do
    it 'is enabled when the given value is true' do
      logging.debugging(true)
      expect(logging.debugging?).to be true
    end

    it 'is disabled when the given value is false' do
      logging.debugging(false)
      expect(logging.debugging?).to be false
    end

    it 'is disabled when the given value is nil' do
      logging.debugging(nil)
      expect(logging.debugging?).to be nil
    end
  end

  describe 'when setting the timing mode' do
    it 'is enabled when the given value is true' do
      logging.timing(true)
      expect(logging.timing?).to be true
    end

    it 'is disabled when the given value is false' do
      logging.timing(false)
      expect(logging.timing?).to be false
    end

    it 'is disabled when the given value is nil' do
      logging.timing(nil)
      expect(logging.timing?).to be nil
    end
  end

  describe 'without a logging callback' do
    before do
      logging.timing(true)
      logging.debugging(true)
      logging.on_message
    end

    it 'calls puts for debug' do
      expect(logging).to receive(:puts).with(logging::GREEN + 'foo' + logging::RESET).once
      logging.debug('foo')
    end

    it 'calls puts for debugonce' do
      expect(logging).to receive(:puts).with(logging::GREEN + 'foo' + logging::RESET).once
      logging.debugonce('foo')
      logging.debugonce('foo')
    end

    it 'calls Kernel.warn for warn' do
      expect(Kernel).to receive(:warn).with('foo').once
      logging.warn('foo')
    end

    it 'calls Kernel.warn for warnonce' do
      expect(Kernel).to receive(:warn).with('foo').once
      logging.warnonce('foo')
      logging.warnonce('foo')
    end

    it 'calls $stderr.puts for timing' do
      expect($stderr).to receive(:puts).with(logging::GREEN + 'foo' + logging::RESET).once
      logging.show_time('foo')
    end
  end

  describe 'with a logging callback' do
    before do
      logging.debugging(true)
      logging.timing(true)
      logging.on_message
    end

    def log_message(level, message)
      called = false
      logging.on_message do |lvl, msg|
        called = true
        expect(lvl).to eq(level)
        expect(msg).to eq(message)
      end
      case level
      when :debug
        LegacyFacter.debug(message)
      when :warn
        LegacyFacter.warn(message)
      when :info
        LegacyFacter.show_time(message)
      else
        raise 'unexpected logging level'
      end
      logging.on_message
      expect(called).to be true
      true
    end

    def log_message_once(level, message)
      calls = 0
      logging.on_message do |lvl, msg|
        expect(lvl).to eq(level)
        expect(msg).to eq(message)
        calls += 1
      end
      case level
      when :debug
        LegacyFacter.debugonce(message)
        LegacyFacter.debugonce(message)
      when :warn
        LegacyFacter.warnonce(message)
        LegacyFacter.warnonce(message)
      else
        raise 'unexpected logging level'
      end
      expect(calls).to eq(1)
    end

    it 'does not call puts for debug or debugonce' do
      logging.on_message {}
      expect(logging).not_to receive(:puts)
      logging.debug('debug message')
      logging.debugonce('debug once message')
    end

    it 'passes debug messages to callback' do
      log_message(:debug, 'debug message')
      log_message_once(:debug, 'debug once message')
    end

    it 'does not call Kernel.warn for warn or warnonce' do
      logging.on_message {}
      expect(Kernel).not_to receive(:warn)
      logging.warn('warn message')
      logging.warnonce('warn once message')
    end

    it 'passes warning messages to callback' do
      log_message(:warn, 'warn message')
      log_message_once(:warn, 'warn once message')
    end

    it 'does not call $stderr.puts for show_time' do
      logging.on_message {}
      expect($stderr).not_to receive(:puts)
      logging.show_time('debug message')
    end

    it 'passes info messages to callback' do
      log_message(:info, 'timing message')
    end
  end

  describe '#format_exception' do
    context 'when trace options is true' do
      let(:trace) { true }
      let(:message) { 'Some error message' }
      let(:exception) { FlushFakeError.new }
      let(:expected_message) { "\e[31mSome error message\nbacktrace:\nprog.rb:2:in `a'\e[0m" }

      it 'format exception to display backtrace' do
        exception.set_backtrace("prog.rb:2:in `a'")
        expect(LegacyFacter.format_exception(exception, message, trace)).to eql(expected_message)
      end
    end
  end
end
