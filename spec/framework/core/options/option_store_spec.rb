# frozen_string_literal: true

describe Facter::OptionStore do
  subject(:option_store) { Facter::OptionStore }

  before do
    option_store.reset
  end

  after do
    option_store.reset
  end

  describe '#all' do
    it 'returns default values' do
      expect(option_store.all).to eq(
        block: true,
        block_list: {},
        blocked_facts: [],
        cli: nil,
        custom_dir: [],
        config_file_custom_dir: [],
        custom_facts: true,
        debug: false,
        external_dir: [],
        config_file_external_dir: [],
        default_external_dir: [],
        external_facts: true,
        fact_groups: {},
        log_level: :warn,
        ruby: true,
        show_legacy: true,
        user_query: [],
        verbose: false,
        config: nil,
        cache: true,
        color: false
      )
    end
  end

  describe '#ruby=' do
    context 'when true' do
      it 'sets ruby to true' do
        option_store.ruby = true
        expect(option_store.ruby).to be true
      end
    end

    context 'when false' do
      before do
        option_store.ruby = false
      end

      it 'sets ruby to false' do
        expect(option_store.ruby).to be false
      end

      it 'sets custom facts to false' do
        expect(option_store.custom_facts).to be false
      end

      it 'adds ruby to blocked facts' do
        expect(option_store.blocked_facts).to include('ruby')
      end
    end
  end

  describe '#external_dir' do
    context 'with external_dir with values' do
      before do
        option_store.external_dir = ['external_dir_path']
      end

      it 'returns external_dir' do
        expect(option_store.external_dir).to eq(['external_dir_path'])
      end
    end

    context 'with @external_facts false' do
      before do
        option_store.external_facts = false
      end

      it 'returns external dir' do
        expect(option_store.external_dir).to be_empty
      end
    end

    context 'with @external_facts true and external_dir empty' do
      before do
        option_store.external_facts = true
        option_store.external_dir = []
      end

      context 'with @config_file_external_dir empty' do
        before do
          option_store.config_file_external_dir = []
          option_store.default_external_dir = ['/default_path']
        end

        it 'returns default dir' do
          expect(option_store.external_dir).to eq(['/default_path'])
        end
      end

      context 'with @config_file_external_dir with values' do
        before do
          option_store.config_file_external_dir = ['/path_from_config_file']
        end

        it 'returns default dir' do
          expect(option_store.external_dir).to eq(['/path_from_config_file'])
        end
      end
    end
  end

  describe '#blocked_facts=' do
    context 'with empty array' do
      it 'does not override existing array' do
        option_store.blocked_facts = ['os']

        option_store.blocked_facts = []

        expect(option_store.blocked_facts).to eq(['os'])
      end
    end

    context 'with array' do
      it 'appends dirs' do
        option_store.blocked_facts = ['os']

        option_store.blocked_facts = ['os2']

        expect(option_store.blocked_facts).to eq(%w[os os2])
      end
    end
  end

  describe '#custom_dir' do
    context 'when @custom_dir has values' do
      before do
        option_store.custom_dir = ['/custom_dir_path']
      end

      it 'returns custom_dir' do
        expect(option_store.custom_dir).to eq(['/custom_dir_path'])
      end
    end

    context 'when @custom_dir is empty' do
      before do
        option_store.custom_dir = []
        option_store.config_file_custom_dir = ['/path_from_config_file']
      end

      it 'returns config_file_custom_dir' do
        expect(option_store.custom_dir).to eq(['/path_from_config_file'])
      end
    end
  end

  describe '#custom_dir=' do
    context 'with array' do
      it 'overrides dirs' do
        option_store.custom_dir = ['/customdir1']

        option_store.custom_dir = ['/customdir2']

        expect(option_store.custom_dir).to eq(['/customdir2'])
      end

      it 'sets ruby to true' do
        option_store.instance_variable_set(:@ruby, false)

        expect do
          option_store.custom_dir = ['/customdir1']
        end.to change(option_store, :ruby)
          .from(false).to(true)
      end
    end
  end

  describe '#debug' do
    context 'when true' do
      it 'sets debug to true and log_level to :debug' do
        expect do
          option_store.debug = true
        end.to change(option_store, :log_level)
          .from(:warn).to(:debug)
      end
    end

    context 'when false' do
      it 'sets log_level to default (:warn)' do
        option_store.instance_variable_set(:@log_level, :info)

        expect do
          option_store.debug = false
        end.to change(option_store, :log_level)
          .from(:info).to(:warn)
      end
    end
  end

  describe '#verbose=' do
    context 'when true' do
      it 'sets log_level to :info' do
        expect do
          option_store.verbose = true
        end.to change(option_store, :log_level)
          .from(:warn).to(:info)
      end
    end

    context 'when false' do
      it 'sets log_level to default (:warn)' do
        option_store.instance_variable_set(:@log_level, :debug)

        expect do
          option_store.debug = false
        end.to change(option_store, :log_level)
          .from(:debug).to(:warn)
      end
    end
  end

  describe '#custom_facts=' do
    context 'when true' do
      it 'sets ruby to true' do
        option_store.instance_variable_set(:@ruby, false)

        expect do
          option_store.custom_facts = true
        end.to change(option_store, :ruby)
          .from(false).to(true)
      end
    end
  end

  describe '#log_level=' do
    let(:facter_log) { class_spy('Facter::Log') }

    before do
      stub_const('Facter::Log', facter_log)
      allow(Facter).to receive(:trace)
    end

    context 'when :trace' do
      it 'sets log_level to :debug' do
        expect do
          option_store.log_level = :trace
        end.to change(option_store, :log_level)
          .from(:warn).to(:debug)
      end

      it 'sets the Facter::Log level' do
        option_store.trace = true
        expect(Facter).to have_received(:trace).with(true)
      end
    end

    context 'when :debug' do
      it 'sets logl_level :debug' do
        expect do
          option_store.log_level = :debug
        end.to change(option_store, :log_level)
          .from(:warn).to(:debug)
      end
    end

    context 'when :info' do
      it 'sets log_level to :info' do
        expect do
          option_store.log_level = :info
        end.to change(option_store, :log_level)
          .from(:warn).to(:info)
      end
    end
  end

  describe '#show_legacy=' do
    context 'when true' do
      it 'sets ruby to true' do
        option_store.instance_variable_set(:@ruby, false)

        expect do
          option_store.show_legacy = true
        end.to change(option_store, :ruby)
          .from(false).to(true)
      end
    end

    context 'when false' do
      it 'sets show_legacy to false' do
        option_store.show_legacy = false
        expect(option_store.show_legacy).to be false
      end
    end
  end

  describe '#send' do
    it 'sets values for attributes' do
      option_store.instance_variable_set(:@ruby, true)

      expect do
        option_store.set('ruby', false)
      end.to change(option_store, :ruby)
        .from(true).to(false)
    end
  end
end
