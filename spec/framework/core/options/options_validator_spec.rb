# frozen_string_literal: true

describe Facter::OptionsValidator do
  describe '#validate' do
    let(:logger) { instance_spy(Facter::Log) }

    context 'when options are invalid pairs' do
      let(:options) { ['--puppet', '--no-ruby'] }
      let(:error_code) { 1 }

      it 'writes message and exit' do
        allow(logger).to receive(:error).with('--puppet and --no-ruby options conflict:'\
                                                                                    ' please specify only one.', true)
        allow(Facter::Cli).to receive(:start).with(['--help'])

        expect { Facter::OptionsValidator.validate(options) }.to raise_error(
          an_instance_of(SystemExit)
              .and(having_attributes(status: error_code))
        )
      end
    end

    context 'when options are duplicated' do
      let(:options) { ['--puppet', '-p'] }
      let(:error_code) { 1 }

      it 'writes message and exit' do
        allow(logger).to receive(:error).with('option --puppet '\
                                                                         'cannot be specified more than once.', true)
        allow(Facter::Cli).to receive(:start).with(['--help'])

        expect { Facter::OptionsValidator.validate(options) }.to raise_error(
          an_instance_of(SystemExit)
              .and(having_attributes(status: error_code))
        )
      end
    end

    context 'when options are valid' do
      let(:options) { ['--puppet', '--no-external-facts'] }

      it 'writes message and exit' do
        expect { Facter::OptionsValidator.validate(options) }.not_to raise_error
      end
    end
  end
end
