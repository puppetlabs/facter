# frozen_string_literal: true

describe Logger do
  let(:file_logger_double) { double(Logger) }
  let(:multi_logger_double) { double(Facter::MultiLogger) }

  before do
    Facter::Log.class_variable_set(:@@file_logger, file_logger_double)
    Facter::Log.class_variable_set(:@@logger, multi_logger_double)

    allow(file_logger_double).to receive(:formatter=)
  end

  describe '#initialize' do
    it 'sets formatters' do
      expect(file_logger_double).to receive(:formatter=)

      Facter::Log.new(Class)
    end
  end

  describe '#debug' do
    it 'writes debug message' do
      expect(multi_logger_double).to receive(:debug).with('Class - debug_message')
      log = Facter::Log.new(Class)
      log.debug('debug_message')
    end
  end

  describe '#info' do
    it 'writes info message' do
      expect(multi_logger_double).to receive(:info).with('Class - info_message')
      log = Facter::Log.new(Class)
      log.info('info_message')
    end
  end

  describe '#warn' do
    it 'writes warn message' do
      expect(multi_logger_double).to receive(:warn).with('Class - warn_message')
      log = Facter::Log.new(Class)
      log.warn('warn_message')
    end
  end

  describe '#error' do
    it 'writes error message with color on macosx' do
      allow(OsDetector.instance).to receive(:detect).and_return(:macosx)
      expect(multi_logger_double).to receive(:error).with("Class - \e[31merror_message\e[0m")
      log = Facter::Log.new(Class)
      log.error('error_message', true)
    end

    it 'writes error message not colorized on Windows' do
      allow(OsDetector.instance).to receive(:detect).and_return(:windows)
      expect(multi_logger_double).to receive(:error).with('Class - error_message')
      log = Facter::Log.new(Class)
      log.error('error_message', true)
    end

    it 'writes error message' do
      expect(multi_logger_double).to receive(:error).with('Class - error_message')
      log = Facter::Log.new(Class)
      log.error('error_message')
    end
  end

  describe '#level=' do
    it 'sets the log level' do
      expect(multi_logger_double).to receive(:level=).with(:error)
      Facter::Log.level = :error
    end
  end

  describe '#level' do
    it 'get the log level' do
      expect(multi_logger_double).to receive(:level).and_return(:warn)
      expect(Facter::Log.level).to eq(:warn)
    end
  end
end
