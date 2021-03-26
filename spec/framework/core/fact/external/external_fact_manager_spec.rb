# frozen_string_literal: true

describe Facter::ExternalFactManager do
  describe '#resolve' do
    let(:custom_fact_name) { 'my_custom_fact' }
    let(:custom_fact_value) { 'custom_fact_value' }
    let(:custom_fact) do
      instance_spy(
        Facter::Util::Fact,
        name: custom_fact_name,
        value: custom_fact_value,
        options: { fact_type: :external, value: 'external' }
      )
    end
    let(:fact_attributes) do
      Facter::FactAttributes.new(user_query: '', filter_tokens: [], structured: false)
    end
    let(:searched_fact) do
      Facter::SearchedFact.new(custom_fact_name, nil, :custom, fact_attributes)
    end
    let(:custom_fact_manager) { Facter::ExternalFactManager.new }

    before do
      allow(LegacyFacter).to receive(:[]).with(custom_fact_name).and_return(custom_fact)
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

    context 'with structured external facts' do
      let(:fact_attributes) do
        Facter::FactAttributes.new(user_query: '', filter_tokens: [], structured: true)
      end
      let(:searched_fact) do
        Facter::SearchedFact.new(custom_fact_name, nil, :external, fact_attributes)
      end

      it 'reads the value from fact options' do
        resolved_facts = custom_fact_manager.resolve_facts([searched_fact])
        expect(resolved_facts.first.value).to eq('external')
      end
    end
  end
end
