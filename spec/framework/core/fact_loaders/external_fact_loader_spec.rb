# frozen_string_literal: true

describe 'ExternalFactLoader' do
  describe '#initialize' do
    let(:collection) { double(LegacyFacter::Util::Collection) }

    before do
      allow(LegacyFacter).to receive(:collection).and_return(collection)
      allow(collection).to receive(:external_facts).and_return({})
      allow(collection).to receive(:custom_facts).and_return([])
    end

    it 'loads one custom fact' do
      allow(collection).to receive(:custom_facts).and_return(['custom_fact'])
      external_fact_loader = Facter::ExternalFactLoader.new

      expect(external_fact_loader.facts.size).to eq(1)
      expect(external_fact_loader.facts.first.name).to eq('custom_fact')
    end

    it 'loads no custom facts' do
      allow(collection).to receive(:custom_facts).and_return([])
      external_fact_loader = Facter::ExternalFactLoader.new

      expect(external_fact_loader.facts).to eq([])
    end

    context 'options' do
      before do
        allow(collection).to receive(:custom_facts).and_return([])
        allow(collection).to receive(:external_facts).and_return([])
      end

      context 'custom fact options' do
        it 'blocks custom facts' do
          expect(Facter::Options).to receive(:custom_dir?).and_return(false)
          expect(LegacyFacter).not_to receive(:search)
          Facter::ExternalFactLoader.new
        end

        it 'does not blocks custom facts' do
          expect(Facter::Options).to receive(:custom_dir?).and_return(true)
          expect(Facter::Options).to receive(:custom_dir).and_return(['custom_fact_dir'])

          expect(LegacyFacter).to receive(:search).with('custom_fact_dir')
          Facter::ExternalFactLoader.new
        end
      end

      context 'external fact options' do
        it 'blocks external facts' do
          allow(Facter::Options).to receive(:external_dir?).and_return(false)

          expect(LegacyFacter).not_to receive(:search_external)
          Facter::ExternalFactLoader.new
        end

        it 'does not blocks external facts' do
          allow(Facter::Options).to receive(:external_dir?).and_return(true)
          allow(Facter::Options).to receive(:external_dir).and_return(['external_fact_dir'])

          expect(LegacyFacter).to receive(:search_external).with(['external_fact_dir'])
          Facter::ExternalFactLoader.new
        end
      end
    end
  end
end
