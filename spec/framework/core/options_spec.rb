# frozen_string_literal: true

describe Facter::Options do
  subject(:options) { Facter::Options }

  describe '#init_from_cli' do
    let(:option_store) { class_spy('Facter::OptionStore') }
    let(:config_file_options) { class_spy('Facter::ConfigFileOptions') }
    let(:options_validator) { class_spy('Facter::OptionsValidator') }

    before do
      stub_const('Facter::ConfigFileOptions', config_file_options)
      stub_const('Facter::OptionStore', option_store)
      stub_const('Facter::OptionsValidator', options_validator)
      allow(config_file_options).to receive(:get).and_return({})
    end

    it 'calls OptionStore with cli' do
      Facter::Options.init_from_cli

      expect(option_store).to have_received(:cli=).with(true)
    end

    it 'calls OptionStore with show_legacy' do
      Facter::Options.init_from_cli

      expect(option_store).to have_received(:show_legacy=).with(false)
    end

    context 'with config_file' do
      let(:config_file_opts) { { 'debug' => true, 'ruby' => true } }

      before do
        allow(config_file_options).to receive(:get).and_return(config_file_opts)
      end

      it 'calls ConfigFileOptions.init with config_path' do
        Facter::Options.init_from_cli(config: 'path/to/config')

        expect(config_file_options).to have_received(:init).with('path/to/config')
      end

      it 'calls OptionStore.set.init with cli_options' do
        Facter::Options.init_from_cli

        config_file_opts.each do |key, value|
          expect(option_store).to have_received(:set).with(key, value)
        end
      end
    end

    context 'with cli_options' do
      let(:cli_options) { { 'debug' => true, 'ruby' => true } }

      it 'calls OptionStore.set.init with cli_options' do
        Facter::Options.init_from_cli(cli_options)

        cli_options.each do |key, value|
          expect(option_store).to have_received(:set).with(key, value)
        end
      end

      context 'with log_level as option' do
        it 'munges the value none to unknown' do
          Facter::Options.init_from_cli({ 'log_level' => 'none' })

          expect(option_store).to have_received(:set).with('log_level', 'unknown')
        end

        it 'munges the value log_level to empty string' do
          Facter::Options.init_from_cli({ 'log_level' => 'log_level' })

          expect(option_store).to have_received(:set).with('log_level', '')
        end

        it 'leaves known log level unmunged' do
          Facter::Options.init_from_cli({ 'log_level' => 'debug' })

          expect(option_store).to have_received(:set).with('log_level', 'debug')
        end
      end
    end
  end

  describe '#init' do
    let(:option_store) { class_spy('Facter::OptionStore') }
    let(:config_file_options) { class_spy('Facter::ConfigFileOptions') }

    before do
      stub_const('Facter::ConfigFileOptions', config_file_options)
      stub_const('Facter::OptionStore', option_store)
      allow(config_file_options).to receive(:get).and_return({})
    end

    it 'calls OptionStore with cli' do
      Facter::Options.init

      expect(option_store).to have_received(:cli=).with(false)
    end

    context 'with config_file' do
      let(:config_file_opts) { { 'debug' => true, 'ruby' => true } }

      before do
        allow(config_file_options).to receive(:get).and_return(config_file_opts)
      end

      it 'calls OptionStore.set.init with cli_options' do
        Facter::Options.init

        config_file_opts.each do |key, value|
          expect(option_store).to have_received(:set).with(key, value)
        end
      end
    end
  end
end
