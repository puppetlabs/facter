# frozen_string_literal: true

describe Logger do
  subject(:log) { Facter::Log.new(Class) }

  let(:multi_logger_double) { instance_spy(Logger) }

  before do
    Facter::Log.class_variable_set(:@@logger, multi_logger_double)
    Facter::Options[:color] = false
  end

  after do
    Facter::Log.class_variable_set(:@@logger, Logger.new(STDOUT))
  end

  describe '#debug' do
    before do
      allow(Facter).to receive(:debugging?).and_return(true)
    end

    context 'when debugging is set to false' do
      it 'no debug messages are sent' do
        allow(Facter).to receive(:debugging?).and_return(false)

        log.debug('info_message')

        expect(multi_logger_double).not_to have_received(:debug)
      end
    end

    it 'logs a warn if message is nil' do
      log.debug(nil)

      expect(multi_logger_double).to have_received(:warn).with(/debug invoked with invalid message/)
    end

    it 'logs a warn if message is empty' do
      log.debug('')

      expect(multi_logger_double).to have_received(:warn).with(/debug invoked with invalid message/)
    end

    shared_examples 'writes debug message' do
      it 'calls debug on multi_logger' do
        log.debug('debug_message')

        expect(multi_logger_double).to have_received(:debug).with('Class - debug_message')
      end
    end

    it_behaves_like 'writes debug message'

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

      it_behaves_like 'writes debug message'

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

        it 'print CYAN (36) debug message' do
          log.debug('debug_message')

          expect(multi_logger_double).to have_received(:debug).with("Class - \e[0;36mdebug_message\e[0m")
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

        it 'print debug message' do
          log.debug('debug_message')

          expect(multi_logger_double).to have_received(:debug).with('Class - debug_message')
        end
      end
    end
  end

  describe '#info' do
    it 'writes info message' do
      log.info('info_message')

      expect(multi_logger_double).to have_received(:info).with('Class - info_message')
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
          log.info('info_message')

          expect(multi_logger_double).to have_received(:info).with("Class - \e[0;32minfo_message\e[0m")
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
          log.info('info_message')

          expect(multi_logger_double).to have_received(:info).with('Class - info_message')
        end
      end
    end
  end

  describe '#warn' do
    it 'writes warn message' do
      log.warn('warn_message')

      expect(multi_logger_double).to have_received(:warn).with('Class - warn_message')
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
          log.warn('warn_message')

          expect(multi_logger_double).to have_received(:warn).with("Class - \e[0;33mwarn_message\e[0m")
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
          log.warn('warn_message')

          expect(multi_logger_double).to have_received(:warn).with('Class - warn_message')
        end
      end
    end
  end

  describe '#error' do
    it 'writes error message with color on macosx' do
      allow(OsDetector.instance).to receive(:detect).and_return(:macosx)

      log.error('error_message', true)

      expect(multi_logger_double).to have_received(:error).with("Class - \e[0;31merror_message\e[0m")
    end

    it 'writes error message not colorized on Windows' do
      allow(OsDetector.instance).to receive(:identifier).and_return(:windows)

      log.error('error_message', true)

      expect(multi_logger_double).to have_received(:error).with('Class - error_message')
    end

    it 'writes error message' do
      log.error('error_message')

      expect(multi_logger_double).to have_received(:error).with('Class - error_message')
    end
  end

  describe '#level=' do
    it 'sets the log level' do
      Facter::Log.level = :error

      expect(multi_logger_double).to have_received(:level=).with(:error)
    end
  end
end
