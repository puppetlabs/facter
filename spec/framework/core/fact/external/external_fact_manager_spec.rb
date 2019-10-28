# frozen_string_literal: true

describe 'CustomFactManager' do
  describe '#resolve' do
    it 'resolved one custom fact' do
      custom_fact_name = 'my_custom_fact'
      custom_fact_value = 'custom_fact_value'

      allow(LegacyFacter).to receive(:search)
      allow(LegacyFacter).to receive(:search_external)
      allow(LegacyFacter).to receive(:value).with(custom_fact_name).and_return(custom_fact_value)

      searched_fact = double(Facter::SearchedFact, name: custom_fact_name, fact_class: nil, filter_tokens: [],
                                                   user_query: '', type: :custom)

      custom_fact_manager = Facter::ExternalFactManager.new
      resolved_facts = custom_fact_manager.resolve_facts([searched_fact])

      expect(resolved_facts.length).to eq(1)
      expect(resolved_facts.first.name).to eq(custom_fact_name)
      expect(resolved_facts.first.value).to eq(custom_fact_value)
    end
  end
end
