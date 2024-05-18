# frozen_string_literal: true

describe Logger do
  subject(:log) { Facter::Log.new(Class) }

  let(:logger) { Facter::Log.class_variable_get(:@@logger) }

  before do
    Facter::Options[:color] = false
  end

  describe '#debug' do
    before do
      allow(Facter).to receive(:debugging?).and_return(true)
    end

    context 'when debugging is set to false' do
      it 'no debug messages are sent' do
        allow(Facter).to receive(:debugging?).and_return(false)

        expect(logger).not_to receive(:debug)

        log.debug('info_message')
      end
    end

    shared_examples 'writes debug message with no color' do
      it 'calls debug on logger' do
        expect(logger).to receive(:debug).with('Class - debug_message')

        log.debug('debug_message')
      end
    end

    shared_examples 'writes debug message with color' do
      it 'calls debug on logger' do
        expect(logger).to receive(:debug)
          .with("Class - #{Facter::CYAN}debug_message#{Facter::RESET}")

        log.debug('debug_message')
      end
    end

    it_behaves_like 'writes debug message with no color'

    context 'when message callback is provided' do
      after do
        Facter::Log.class_variable_set(:@@message_callback, nil)
      end

      it 'provides on_message hook' do
        logger_double = instance_spy(Logger)
        Facter.on_message do |level, message|
          logger_double.debug("on_message called with level: #{level}, message: #{message}")
        end

        log.debug('test')

        expect(logger_double).to have_received(:debug).with('on_message called with level: debug, message: test')
      end
    end

    context 'when call is made during os detection in os_detector.rb and facter.rb is not fully loaded' do
      before do
        allow(Facter).to receive(:respond_to?).with(:debugging?).and_return(false)
      end

      it_behaves_like 'writes debug message with no color'

      it 'does not call Facter.debugging?' do
        log.debug('debug_message')

        expect(Facter).not_to have_received(:debugging?)
      end
    end

    context 'when non Windows OS' do
      before do
        allow(OsDetector.instance).to receive(:identifier).and_return(:macosx)
      end

      context 'when --colorize option is enabled' do
        before do
          Facter::Options[:color] = true
        end

        it_behaves_like 'writes debug message with color'
      end
    end

    context 'when Windows OS' do
      before do
        allow(OsDetector.instance).to receive(:identifier).and_return(:windows)
      end

      context 'when --colorize option is enabled' do
        before do
          Facter::Options[:color] = true
        end

        it_behaves_like 'writes debug message with color'
      end
    end
  end

  describe '#debugonce' do
    before do
      allow(Facter).to receive(:debugging?).and_return(true)
    end

    it 'writes the same debug message only once' do
      message = 'Some error message'

      expect(logger).to receive(:debug).once.with("Class - #{message}")

      log.debugonce(message)
      log.debugonce(message)
    end
  end

  describe '#info' do
    it 'writes info message' do
      expect(logger).to receive(:info).with('Class - info_message')

      log.info('info_message')
    end

    context 'when non Windows OS' do
      before do
        allow(OsDetector.instance).to receive(:identifier).and_return(:macosx)
      end

      context 'when --colorize option is enabled' do
        before do
          Facter::Options[:color] = true
        end

        it 'print Green (32) info message' do
          expect(logger)
            .to receive(:info)
            .with("Class - #{Facter::GREEN}info_message#{Facter::RESET}")

          log.info('info_message')
        end
      end
    end

    context 'when Windows OS' do
      before do
        allow(OsDetector.instance).to receive(:identifier).and_return(:windows)
      end

      context 'when --colorize option is enabled' do
        before do
          Facter::Options[:color] = true
        end

        it 'print info message' do
          expect(logger).to receive(:info)
            .with("Class - #{Facter::GREEN}info_message#{Facter::RESET}")

          log.info('info_message')
        end
      end
    end
  end

  describe '#warn' do
    it 'writes warn message' do
      expect(logger).to receive(:warn).with('Class - warn_message')

      log.warn('warn_message')
    end

    context 'when non Windows OS' do
      before do
        allow(OsDetector.instance).to receive(:identifier).and_return(:macosx)
      end

      context 'when --colorize option is enabled' do
        before do
          Facter::Options[:color] = true
        end

        it 'print Yellow (33) info message' do
          expect(logger)
            .to receive(:warn)
            .with("Class - #{Facter::YELLOW}warn_message#{Facter::RESET}")

          log.warn('warn_message')
        end
      end
    end

    context 'when Windows OS' do
      before do
        allow(OsDetector.instance).to receive(:identifier).and_return(:windows)
      end

      context 'when --colorize option is enabled' do
        before do
          Facter::Options[:color] = true
        end

        it 'print warn message' do
          expect(logger).to receive(:warn)
            .with("Class - #{Facter::YELLOW}warn_message#{Facter::RESET}")

          log.warn('warn_message')
        end
      end
    end
  end

  describe '#warnonce' do
    before do
      allow(Facter).to receive(:debugging?).and_return(true)
    end

    it 'writes the same debug message only once' do
      message = 'Some error message'

      expect(logger).to receive(:warn).once.with("Class - #{message}")

      log.warnonce(message)
      log.warnonce(message)
    end
  end

  describe '#error' do
    it 'writes error message with color on macosx' do
      allow(OsDetector.instance).to receive(:detect).and_return(:macosx)

      expect(logger).to receive(:error).with("Class - #{Facter::RED}error_message#{Facter::RESET}")

      log.error('error_message', true)
    end

    it 'writes error message colorized on Windows' do
      allow(OsDetector.instance).to receive(:identifier).and_return(:windows)

      expect(logger).to receive(:error).with("Class - #{Facter::RED}error_message#{Facter::RESET}")

      log.error('error_message', true)
    end

    it 'writes error message' do
      expect(logger).to receive(:error).with('Class - error_message')

      log.error('error_message')
    end
  end

  describe '#level=' do
    it 'sets the log level' do
      expect(logger).to receive(:level=).with(:error)

      Facter::Log.level = :error
    end
  end

  describe '#log_exception' do
    let(:exception) { Exception.new('Test exception') }

    it 'writes exception message without --trace option' do
      expect(logger).to receive(:error).with("Class - #{colorize('Test exception', Facter::RED)}")

      log.log_exception(exception)
    end

    it 'writes exception message and backtrace with --trace option' do
      allow(Facter::Options).to receive(:[])
      allow(Facter::Options).to receive(:[]).with(:trace).and_return(true)
      allow(exception).to receive(:backtrace).and_return(['backtrace:1'])

      expect(logger)
        .to receive(:error)
        .with("Class - #{colorize("Test exception\nbacktrace:1", Facter::RED)}")

      log.log_exception(exception)
    end
  end

  describe '.clear_messages' do
    before do
      allow(Facter).to receive(:debugging?).and_return(true)
    end

    it 'clears debugonce messages' do
      message = 'Some error message'

      expect(logger).to receive(:debug).twice.with("Class - #{message}")

      log.debugonce(message)
      Facter::Log.clear_messages
      log.debugonce(message)
    end

    it 'clears warnonce messages' do
      message = 'Some error message'

      expect(logger).to receive(:warn).twice.with("Class - #{message}")

      log.warnonce(message)
      Facter::Log.clear_messages
      log.warnonce(message)
    end
  end

  describe '.show_time' do
    before do
      allow(Facter::Log).to receive(:timing?).and_return(true)
    end

    it 'prints the message to stderr' do
      expect { Facter::Log.show_time('foo') }.to output("\e[32mfoo\e[0m\n").to_stderr
    end
  end

  describe 'setting the timing mode' do
    it 'is enabled when the given value is true' do
      Facter::Log.timing(true)
      expect(Facter::Log.timing?).to be true
    end

    it 'is disabled when the given value is false' do
      Facter::Log.timing(false)
      expect(Facter::Log.timing?).to be false
    end

    it 'is disabled when the given value is nil' do
      Facter::Log.timing(nil)
      expect(Facter::Log.timing?).to be nil
    end
  end
end
