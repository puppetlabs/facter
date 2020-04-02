# frozen_string_literal: true

describe Facter::ExternalFactLoader do
  let(:collection) { double(LegacyFacter::Util::Collection) }

  before do
    allow(LegacyFacter).to receive(:collection).and_return(collection)
    allow(collection).to receive(:external_facts).and_return({})
    allow(collection).to receive(:custom_facts).and_return([])
  end

  describe '#custom_facts' do
    context 'when one custom fact is loaded' do
      before do
        allow(collection).to receive(:custom_facts).and_return(['custom_fact'])
        allow(Facter::Options).to receive(:custom_dir?).and_return(true)
        allow(Facter::Options).to receive(:custom_dir).and_return(['custom_fact_dir'])
      end

      it 'returns one custom fact' do
        external_fact_loader = Facter::ExternalFactLoader.new
        expect(external_fact_loader.custom_facts.size).to eq(1)
      end

      it 'returns custom fact with name custom_fact' do
        external_fact_loader = Facter::ExternalFactLoader.new
        expect(external_fact_loader.custom_facts.first.name).to eq('custom_fact')
      end
    end

    context 'when no custom facts are loaded' do
      before do
        allow(collection).to receive(:custom_facts).and_return([])
      end

      it 'return no custom facts' do
        external_fact_loader = Facter::ExternalFactLoader.new
        expect(external_fact_loader.custom_facts).to eq([])
      end
    end

    context 'when it blocks custom facts' do
      before do
        allow(collection).to receive(:custom_facts).and_return([])
      end

      it 'does not load custom facts (does not call LegacyFacter.search)' do
        allow(Facter::Options).to receive(:custom_dir?).and_return(false)
        expect(LegacyFacter).not_to receive(:search)

        external_fact_loader = Facter::ExternalFactLoader.new
        external_fact_loader.custom_facts
      end
    end
  end

  describe '#external_facts' do
    context 'when loads one external fact' do
      before do
        allow(collection).to receive(:external_facts).and_return(['external_fact'])
        allow(Facter::Options).to receive(:external_dir?).and_return(true)
        allow(Facter::Options).to receive(:external_dir).and_return(['external_fact_dir'])
      end

      it 'returns one external fact' do
        external_fact_loader = Facter::ExternalFactLoader.new
        expect(external_fact_loader.external_facts.size).to eq(1)
      end

      it 'returns external fact with name external_fact' do
        external_fact_loader = Facter::ExternalFactLoader.new
        expect(external_fact_loader.external_facts.first.name).to eq('external_fact')
      end
    end

    context 'when loads no external facts' do
      before do
        allow(collection).to receive(:external_facts).and_return([])
      end

      it 'return no external facts' do
        external_fact_loader = Facter::ExternalFactLoader.new
        expect(external_fact_loader.external_facts).to eq([])
      end
    end

    context 'when it blocks external facts' do
      before do
        allow(collection).to receive(:external_facts).and_return([])
      end

      it 'does not load custom facts (does not call LegacyFacter.search_external)' do
        allow(Facter::Options).to receive(:external_dir?).and_return(false)
        expect(LegacyFacter).not_to receive(:search_external)

        external_fact_loader = Facter::ExternalFactLoader.new
        external_fact_loader.external_facts
      end
    end
  end
end
