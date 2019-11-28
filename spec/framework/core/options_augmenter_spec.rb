# frozen_string_literal: true

describe 'OptionsAugmenter' do
  before do
    Singleton.__init__(Facter::ConfigReader)
    Singleton.__init__(Facter::BlockList)
  end

  let(:options_augmenter) { Facter::OptionsAugmenter.new({}) }

  describe '#augment_with_cli_options' do
    context 'defined flags to true' do
      let(:cli_config) { { 'debug' => true, 'trace' => true, 'verbose' => true, 'log-level' => 'info' } }

      before do
        allow_any_instance_of(Facter::ConfigReader).to receive('cli').and_return(cli_config)
        options_augmenter.augment_with_cli_options!
      end

      let(:augmented_options) { options_augmenter.options }

      it 'sets debug to true' do
        expect(augmented_options[:debug]).to eq(true)
      end

      it 'sets trace to true' do
        expect(augmented_options[:trace]).to eq(true)
      end

      it 'sets verbose to true' do
        expect(augmented_options[:verbose]).to eq(true)
      end

      it 'sets log-level to info' do
        expect(augmented_options[:log_level]).to eq('info')
      end
    end

    context 'defined flags to false' do
      let(:cli_config) { { 'debug' => false, 'trace' => false, 'verbose' => false, 'log-level' => 'warn' } }

      before do
        allow_any_instance_of(Facter::ConfigReader).to receive('cli').and_return(cli_config)
        options_augmenter.augment_with_cli_options!
      end

      let(:augmented_options) { options_augmenter.options }

      it 'sets debug to false' do
        expect(augmented_options[:debug]).to eq(false)
      end

      it 'sets trace to false' do
        expect(augmented_options[:trace]).to eq(false)
      end

      it 'sets verbose to false' do
        expect(augmented_options[:verbose]).to eq(false)
      end

      it 'sets log-level to warn' do
        expect(augmented_options[:log_level]).to eq('warn')
      end
    end
  end

  describe '#augment_with_global_options!' do
    context 'defined flags' do
      let(:global_config) do
        { 'external-dir' => 'external-dir_value', 'custom-dir' => 'custom-dir_value',
          'no-external-facts' => true, 'no-custom-facts' => true, 'no-ruby' => true }
      end

      before do
        allow_any_instance_of(Facter::ConfigReader).to receive('global').and_return(global_config)
        options_augmenter.augment_with_global_options!
      end

      let(:augmented_options) { options_augmenter.options }

      it 'sets external-dir' do
        expect(augmented_options[:external_dir]).to eq('external-dir_value')
      end

      it 'sets custom-dir' do
        expect(augmented_options[:custom_dir]).to eq('custom-dir_value')
      end

      it 'sets external-facts to false' do
        expect(augmented_options[:external_facts]).to eq(false)
      end

      it 'sets custom-facts to false' do
        expect(augmented_options[:custom_facts]).to eq(false)
      end

      it 'sets ruby to false' do
        expect(augmented_options[:ruby]).to eq(false)
      end
    end

    context 'undefined flags' do
      let(:global_config) { { 'no-external-facts' => false, 'no-custom-facts' => false, 'no-ruby' => false } }

      before do
        allow_any_instance_of(Facter::ConfigReader).to receive('global').and_return(global_config)
        options_augmenter.augment_with_global_options!
      end

      let(:augmented_options) { options_augmenter.options }

      it 'unset external-dir' do
        expect(augmented_options[:external_dir]).to be_nil
      end

      it 'unset custom-dir' do
        expect(augmented_options[:custom_dir]).to be_nil
      end

      it 'sets external-facts to true' do
        expect(augmented_options[:external_facts]).to eq(true)
      end

      it 'sets custom-facts to true' do
        expect(augmented_options[:custom_facts]).to eq(true)
      end

      it 'sets ruby to true' do
        expect(augmented_options[:ruby]).to eq(true)
      end
    end
  end

  describe '#augments_with_facts_options' do
    context 'options set' do
      let(:fact_config) { [{ 'fact' => '13 days' }] }
      let(:block_fact_list) { %w[fact1 fact2 fact3] }

      before do
        allow_any_instance_of(Facter::ConfigReader).to receive('ttls').and_return(fact_config)
        allow_any_instance_of(Facter::BlockList).to receive(:blocked_facts).and_return(block_fact_list)
        options_augmenter.augment_with_facts_options!
      end

      let(:augmented_options) { options_augmenter.options }

      it 'sets ttls' do
        expect(augmented_options[:ttls]).to eq([{ 'fact' => '13 days' }])
      end

      it 'sets block_list' do
        expect(augmented_options[:blocked_facts]).to eq(block_fact_list)
      end
    end

    context 'options not set' do
      before do
        allow_any_instance_of(Facter::ConfigReader).to receive('ttls').and_return(nil)
        allow_any_instance_of(Facter::BlockList).to receive(:blocked_facts).and_return(nil)
        options_augmenter.augment_with_facts_options!
      end

      let(:augmented_options) { options_augmenter.options }

      it 'sets ttls' do
        expect(augmented_options[:ttls]).to be_nil
      end

      it 'sets block_list' do
        expect(augmented_options[:blocked_facts]).to be_nil
      end
    end
  end

  describe '#augment_with_query_options' do
    it 'sets user_query' do
      options_augmenter.augment_with_query_options!(['os'])
      augmented_options = options_augmenter.options

      expect(augmented_options[:user_query]).to eq(true)
    end

    it 'does not set user_query' do
      options_augmenter.augment_with_query_options!([])
      augmented_options = options_augmenter.options

      expect(augmented_options[:user_query]).to be_nil
    end
  end
end
