# frozen_string_literal: true

describe Facter::ConfigReader do
  subject(:config_reader) { Facter::ConfigReader }

  let(:linux_default_path) { File.join('/', 'etc', 'puppetlabs', 'facter', 'facter.conf') }
  let(:windows_default_path) { File.join('C:', 'ProgramData', 'PuppetLabs', 'facter', 'etc', 'facter.conf') }

  before do
    allow(OsDetector.instance).to receive(:identifier).and_return(os)
  end

  describe '#init' do
    before do
      allow(File).to receive(:readable?).and_return(false)
    end

    context 'without config_path sent' do
      context 'with os linux' do
        let(:os) { :linux }

        it 'calls refresh_config with linux path' do
          config_reader.init
          expect(File).to have_received(:readable?).with(linux_default_path)
        end
      end

      context 'with os windows' do
        let(:os) { :windows }

        it 'calls refresh_config with windows path' do
          config_reader.init
          expect(File).to have_received(:readable?).with(windows_default_path)
        end
      end
    end

    context 'with config_path sent' do
      let(:os) { :linux }

      it 'calls refresh_config with custom path' do
        config_reader.init('/path/to/config/file')
        expect(File).to have_received(:readable?).with('/path/to/config/file')
      end
    end
  end

  describe '#block_list' do
    let(:os) { :linux }

    before do
      allow(File).to receive(:readable?).and_return(true)
      allow(Hocon).to receive(:load).and_return(config)
    end

    context 'with empty config file' do
      let(:config) { {} }

      it 'returns nil' do
        config_reader.init

        expect(config_reader.block_list).to eq(nil)
      end
    end

    context 'with blocklist in config file' do
      let(:config) { { 'facts' => { 'blocklist' => %w[group1 fact1] } } }

      it 'returns blocklisted facts' do
        config_reader.init
        expect(config_reader.block_list).to eq(%w[group1 fact1])
      end
    end
  end

  describe '#ttls' do
    let(:os) { :linux }

    before do
      allow(File).to receive(:readable?).and_return(true)
      allow(Hocon).to receive(:load).and_return(config)
    end

    context 'with empty config file' do
      let(:config) { {} }

      it 'returns nil' do
        config_reader.init

        expect(config_reader.ttls).to eq(nil)
      end
    end

    context 'with ttls in config file' do
      let(:config) { { 'facts' => { 'ttls' => [{ 'fact_name' => '10 days' }] } } }

      it 'returns blocklisted facts' do
        config_reader.init

        expect(config_reader.ttls).to eq([{ 'fact_name' => '10 days' }])
      end
    end
  end

  describe '#global' do
    let(:os) { :linux }

    before do
      allow(File).to receive(:readable?).and_return(true)
      allow(Hocon).to receive(:load).and_return(config)
    end

    context 'with empty config file' do
      let(:config) { {} }

      it 'returns nil' do
        config_reader.init

        expect(config_reader.global).to eq(nil)
      end
    end

    context 'with global section in config file' do
      let(:config) { { 'global' => 'global_config' } }

      it 'returns blocklisted facts' do
        config_reader.init

        expect(config_reader.global).to eq('global_config')
      end
    end
  end

  describe '#cli' do
    let(:os) { :linux }

    before do
      allow(File).to receive(:readable?).and_return(true)
      allow(Hocon).to receive(:load).and_return(config)
    end

    context 'with empty config file' do
      let(:config) { {} }

      it 'returns nil' do
        config_reader.init

        expect(config_reader.cli).to eq(nil)
      end
    end

    context 'with cli section in config file' do
      let(:config) { { 'cli' => 'cli_config' } }

      it 'returns blocklisted facts' do
        config_reader.init

        expect(config_reader.cli).to eq('cli_config')
      end
    end
  end
end
