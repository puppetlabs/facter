# frozen_string_literal: true

describe 'ExternalFactLoader' do
  describe '#initialize' do
    let(:collection) { double(LegacyFacter::Util::Collection) }

    before do
      allow(LegacyFacter).to receive(:collection).and_return(collection)
      allow(collection).to receive(:external_facts).and_return({})
    end

    it 'loads one custom fact' do
      allow(collection).to receive(:custom_facts).and_return('os' => nil)
      external_fact_loader = Facter::ExternalFactLoader.new

      expect(external_fact_loader.facts).to eq('os' => nil)
    end

    it 'loads no custom facts' do
      allow(collection).to receive(:custom_facts).and_return({})
      external_fact_loader = Facter::ExternalFactLoader.new

      expect(external_fact_loader.facts).to eq({})
    end
  end
end
