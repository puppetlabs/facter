# frozen_string_literal: true

describe Facter::ExternalFactManager do
  describe '#resolve' do
    let(:custom_fact_name) { 'my_custom_fact' }
    let(:custom_fact_value) { 'custom_fact_value' }
    let(:searched_fact) { Facter::SearchedFact.new(custom_fact_name, nil, [], '', :custom) }
    let(:custom_fact_manager) { Facter::ExternalFactManager.new }

    before do
      allow(LegacyFacter).to receive(:search)
      allow(LegacyFacter).to receive(:search_external)
      allow(LegacyFacter).to receive(:value).with(custom_fact_name).and_return(custom_fact_value)
    end

    it 'resolves one custom fact' do
      resolved_facts = custom_fact_manager.resolve_facts([searched_fact])
      expect(resolved_facts.length).to eq(1)
    end

    it 'resolves custom fact with name my_custom_fact' do
      resolved_facts = custom_fact_manager.resolve_facts([searched_fact])
      expect(resolved_facts.first.name).to eq(custom_fact_name)
    end

    it 'resolves custom fact with value custom_fact_value' do
      resolved_facts = custom_fact_manager.resolve_facts([searched_fact])
      expect(resolved_facts.first.value).to eq(custom_fact_value)
    end
  end
end
