# frozen_string_literal: true

describe 'ExternalFactLoader' do
  describe '#initialize' do
    let(:collection) { double(LegacyFacter::Util::Collection) }

    before do
      allow(LegacyFacter).to receive(:collection).and_return(collection)
      allow(collection).to receive(:external_facts).and_return({})
      allow(collection).to receive(:custom_facts).and_return({})
    end

    it 'loads one custom fact' do
      allow(collection).to receive(:custom_facts).and_return('custom_fact' => nil)
      external_fact_loader = Facter::ExternalFactLoader.new({})

      expect(external_fact_loader.facts.size).to eq(1)
      expect(external_fact_loader.facts.first.name).to eq('custom_fact')
    end

    it 'loads no custom facts' do
      allow(collection).to receive(:custom_facts).and_return({})
      external_fact_loader = Facter::ExternalFactLoader.new({})

      expect(external_fact_loader.facts).to eq([])
    end

    context 'options' do
      before do
        allow(collection).to receive(:custom_facts).and_return({})
        allow(collection).to receive(:external_facts).and_return({})
      end

      context 'custom fact options' do
        it 'received a custom dir' do
          options = { custom_dir: ['custom_fact_dir'] }
          expect(LegacyFacter).to receive(:search).with('custom_fact_dir')
          Facter::ExternalFactLoader.new(options)
        end

        it 'does not receive a custom dir' do
          options = {}
          expect(LegacyFacter).not_to receive(:search)
          Facter::ExternalFactLoader.new(options)
        end

        it 'blocks custom facts' do
          options = { custom_dir: ['custom_fact_dir'], no_custom_facts: true }
          expect(LegacyFacter).not_to receive(:search)
          Facter::ExternalFactLoader.new(options)
        end

        it 'does not blocks custom facts' do
          options = { custom_dir: ['custom_fact_dir'], no_custom_facts: false }
          expect(LegacyFacter).to receive(:search).with('custom_fact_dir')
          Facter::ExternalFactLoader.new(options)
        end
      end

      context 'external fact options' do
        it 'received an external dir' do
          options = { external_dir: ['external_fact_dir'] }
          expect(LegacyFacter).to receive(:search_external).with(['external_fact_dir'])
          Facter::ExternalFactLoader.new(options)
        end

        it 'does not receive an external dir' do
          options = {}
          expect(LegacyFacter).not_to receive(:search_external)
          Facter::ExternalFactLoader.new(options)
        end

        it 'blocks external facts' do
          options = { external_dir: ['external_fact_dir'], no_external_facts: true }
          expect(LegacyFacter).not_to receive(:search_external)
          Facter::ExternalFactLoader.new(options)
        end

        it 'does not blocks external facts' do
          options = { external_dir: ['external_fact_dir'], no_external_facts: false }
          expect(LegacyFacter).to receive(:search_external).with(['external_fact_dir'])
          Facter::ExternalFactLoader.new(options)
        end
      end
    end
  end
end
