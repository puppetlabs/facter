# frozen_string_literal: true

describe Facter::OptionsValidator do
  describe '#validate' do
    let(:logger) { instance_spy(Facter::Log) }

    before do
      allow(Facter::Log).to receive(:new).and_return(logger)
    end

    context 'when CLI options are invalid pairs' do
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

    context 'when config file options are invalid pairs' do
      let(:error_code) { 1 }

      it 'writes message and exit' do
        expect do
          expect do
            Facter::Options.init_from_cli(config: 'spec/fixtures/invalid_option_pairs.conf')
          end.to raise_error(
            an_instance_of(SystemExit)
              .and(having_attributes(status: error_code))
          )
        end.to output(/Usage/).to_stdout
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

    context 'when parsing resolved options' do
      # rubocop:disable Style/BlockDelimiters
      let(:options) {
        { puppet: true, external_facts: false, external_dir: Facter::OptionStore.default_external_dir + [''],
          ruby: true, custom_facts: true }
      }
      # rubocop:enable Style/BlockDelimiters

      it 'writes message and exit' do
        stub_const('Puppet', { pluginfactdest: '' })
        expect { Facter::OptionsValidator.validate_configs(options) }.not_to raise_error
      end
    end
  end
end
