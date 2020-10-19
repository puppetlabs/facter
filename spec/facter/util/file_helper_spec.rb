# frozen_string_literal: true

describe Facter::Util::FileHelper do
  subject(:file_helper) { Facter::Util::FileHelper }

  let(:path) { '/Users/admin/file.txt' }
  let(:content) { 'file content' }
  let(:error_message) do
    "Facter::Util::FileHelper - #{Facter::CYAN}File at: /Users/admin/file.txt is not accessible.#{Facter::RESET}"
  end
  let(:array_content) { ['line 1', 'line 2', 'line 3'] }
  let(:logger_double) { instance_spy(Facter::Log) }

  before do
    Facter::Log.class_variable_set(:@@logger, logger_double)
    allow(Facter).to receive(:debugging?).and_return(true)
    allow(Facter::OptionStore).to receive(:color).and_return(true)
  end

  shared_context 'when file is readable' do
    before do
      allow(File).to receive(:readable?).with(path).and_return(true)
    end
  end

  shared_context 'when file is not readable' do
    before do
      allow(File).to receive(:readable?).with(path).and_return(false)
    end
  end

  describe '#safe_read' do
    before do
      allow(File).to receive(:read).with(path).and_return(content)
    end

    context 'when successfully read the file content' do
      include_context 'when file is readable'

      it 'returns the file content' do
        expect(file_helper.safe_read(path)).to eq(content)
      end

      it 'File.readable? is called with the correct path' do
        file_helper.safe_read(path)

        expect(File).to have_received(:readable?).with(path)
      end

      it 'File.read is called with the correct path' do
        file_helper.safe_read(path)

        expect(File).to have_received(:read).with(path)
      end

      it "doesn't log anything" do
        file_helper.safe_read(path)

        expect(logger_double).not_to have_received(:debug)
      end
    end

    context 'when failed to read the file content' do
      include_context 'when file is not readable'

      it 'returns empty string by default' do
        expect(file_helper.safe_read(path)).to eq('')
      end

      it 'returns nil' do
        expect(file_helper.safe_read(path, nil)).to eq(nil)
      end

      it 'File.readable? is called with the correct path' do
        file_helper.safe_read(path)

        expect(File).to have_received(:readable?).with(path)
      end

      it 'File.read is not called' do
        file_helper.safe_read(path)

        expect(File).not_to have_received(:read)
      end

      it 'logs a debug message' do
        file_helper.safe_read(path)

        expect(logger_double).to have_received(:debug)
          .with(error_message)
      end
    end
  end

  describe '#safe_read_lines' do
    before do
      allow(File).to receive(:readlines).with(path).and_return(array_content)
    end

    context 'when successfully read the file lines' do
      include_context 'when file is readable'

      it 'returns the file content in an array of lines' do
        expect(file_helper.safe_readlines(path)).to eq(array_content)
      end

      it 'File.readable? is called with the correct path' do
        file_helper.safe_readlines(path)

        expect(File).to have_received(:readable?).with(path)
      end

      it 'File.readlines is called with the correct path' do
        file_helper.safe_readlines(path)

        expect(File).to have_received(:readlines).with(path)
      end

      it "doesn't log anything" do
        file_helper.safe_readlines(path)

        expect(logger_double).not_to have_received(:debug)
      end
    end

    context 'when failed to read the file lines' do
      include_context 'when file is not readable'

      it 'returns empty array by default' do
        expect(file_helper.safe_readlines(path)).to eq([])
      end

      it 'returns nil' do
        expect(file_helper.safe_readlines(path, nil)).to eq(nil)
      end

      it 'File.readable? is called with the correct path' do
        file_helper.safe_readlines(path)

        expect(File).to have_received(:readable?).with(path)
      end

      it 'File.readlines is not called' do
        file_helper.safe_readlines(path)

        expect(File).not_to have_received(:readlines)
      end

      it 'logs a debug message' do
        file_helper.safe_read(path)

        expect(logger_double).to have_received(:debug).with(error_message)
      end
    end
  end
end
