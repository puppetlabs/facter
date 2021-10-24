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

        before do
          stub_const('RUBY_PLATFORM', 'linux')
        end

        it 'calls refresh_config with linux path' do
          config_reader.init
          expect(File).to have_received(:readable?).with(linux_default_path)
        end
      end

      context 'with os windows' do
        let(:os) { :windows }

        before do
          stub_const('RUBY_PLATFORM', 'windows')
        end

        it 'calls refresh_config with windows path' do
          config_reader.init
          expect(File).to have_received(:readable?).with(windows_default_path)
        end
      end

      context 'with JRUBY' do
        let(:os) { :linux }

        before do
          stub_const('RUBY_PLATFORM', 'java')
        end

        it 'load no config' do
          config_reader.init
          expect(File).to have_received(:readable?).with('')
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

    context 'with invalid config file' do
      let(:config) { 'some corrupt information' }
      let(:log) { instance_spy(Facter::Log) }

      before do
        allow(Facter::Log).to receive(:new).and_return(log)
        allow(Hocon).to receive(:load).and_raise(StandardError)
        allow(log).to receive(:warn)
      end

      it 'loggs a warning' do
        config_reader.init

        expect(log).to have_received(:warn).with(/Facter failed to read config file/)
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

  describe '#fact-groups' do
    let(:os) { :linux }

    before do
      allow(File).to receive(:readable?).and_return(true)
      allow(Hocon).to receive(:load).and_return(config)
    end

    context 'with empty config file' do
      let(:config) { {} }

      it 'returns nil' do
        config_reader.init

        expect(config_reader.fact_groups).to eq(nil)
      end
    end

    context 'with fact-groups in config file' do
      let(:config) { { 'fact-groups' => { 'cached-custom-facts' => ['my_custom_fact'] } } }

      it 'returns fact-groups' do
        config_reader.init

        expect(config_reader.fact_groups).to eq('cached-custom-facts' => ['my_custom_fact'])
      end
    end
  end
end
