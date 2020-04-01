# frozen_string_literal: true

describe Logger do
  subject(:log) { Facter::Log.new(Class) }

  let(:file_logger_double) { instance_spy(Logger) }
  let(:multi_logger_double) { instance_spy(Facter::MultiLogger, level: :warn) }

  before do
    Facter::Log.class_variable_set(:@@file_logger, file_logger_double)
    Facter::Log.class_variable_set(:@@logger, multi_logger_double)

    allow(file_logger_double).to receive(:formatter=)
  end

  describe '#debug' do
    before do
      allow(Facter).to receive(:debugging?).and_return(true)
    end

    let(:handler) { instance_spy(Logger) }

    it 'noops of debugging is not set' do
      allow(Facter).to receive(:debugging?).and_return(false)
      log.debug('info_message')
      expect(multi_logger_double).not_to have_received(:debug)
    end

    it 'logs a warn if message is nil' do
      log.debug(nil)
      expect(multi_logger_double).to have_received(:warn).with(/debug invoked with invalid message/)
    end

    it 'logs a warn if message is empty' do
      log.debug('')
      expect(multi_logger_double).to have_received(:warn).with(/debug invoked with invalid message/)
    end

    it 'writes debug message' do
      log.debug('debug_message')
      expect(multi_logger_double).to have_received(:debug).with('Class - debug_message')
    end

    it 'provides on_message hook' do
      Facter.on_message do |level, message|
        handler.debug("on_message called with level: #{level}, message: #{message}")
      end

      log.debug('test')

      expect(handler).to have_received(:debug).with('on_message called with level: debug, message: test')
    end
  end

  describe '#info' do
    it 'writes info message' do
      log.info('info_message')
      expect(multi_logger_double).to have_received(:info).with('Class - info_message')
    end
  end

  describe '#warn' do
    it 'writes warn message' do
      log.warn('warn_message')
      expect(multi_logger_double).to have_received(:warn).with('Class - warn_message')
    end
  end

  describe '#error' do
    it 'writes error message with color on macosx' do
      allow(OsDetector.instance).to receive(:detect).and_return(:macosx)
      log.error('error_message', true)
      expect(multi_logger_double).to have_received(:error).with("Class - \e[31merror_message\e[0m")
    end

    it 'writes error message not colorized on Windows' do
      allow(OsDetector.instance).to receive(:detect).and_return(:windows)
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

  describe '#level' do
    it 'get the log level' do
      expect(Facter::Log.level).to eq(:warn)
    end
  end
end
