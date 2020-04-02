# frozen_string_literal: true

describe Facter::FactFilter do
  describe '#filter_facts!' do
    context 'when value is a hash' do
      context 'with hash keys as symbols' do
        let(:fact_value) { { full: '18.7.0', major: '18', minor: 7 } }
        let(:resolved_fact) { Facter::ResolvedFact.new('os.release', fact_value) }

        before do
          resolved_fact.user_query = 'os.release.major'
          resolved_fact.filter_tokens = ['major']
        end

        it 'filters hash value inside fact' do
          Facter::FactFilter.new.filter_facts!([resolved_fact])
          expect(resolved_fact.value).to eq('18')
        end
      end

      context 'when hash keys are strings and symbols' do
        let(:fact_value) { { '/key1' => 'value_1', key2: 'value_2' } }
        let(:resolved_fact) { Facter::ResolvedFact.new('my.fact', fact_value) }

        before do
          resolved_fact.user_query = 'my.fact./key1'
          resolved_fact.filter_tokens = ['/key1']
        end

        it 'filters hash value inside fact' do
          Facter::FactFilter.new.filter_facts!([resolved_fact])
          expect(resolved_fact.value).to eq('value_1')
        end
      end
    end

    context 'with value string' do
      let(:fact_value) { 'value_1' }
      let(:resolved_fact) { Facter::ResolvedFact.new('my.fact', fact_value) }

      before do
        resolved_fact.user_query = 'my.fact'
        resolved_fact.filter_tokens = []
      end

      it 'filters string value inside fact' do
        Facter::FactFilter.new.filter_facts!([resolved_fact])
        expect(resolved_fact.value).to eq('value_1')
      end
    end

    context 'when filter legacy' do
      let(:fact_value) { 'value_1' }
      let(:legacy_resolved_fact) { Facter::ResolvedFact.new('operatingsystem', fact_value, :legacy) }
      let(:core_resolved_fact) { Facter::ResolvedFact.new('os.name', fact_value, :core) }
      let(:searched_facts) { [legacy_resolved_fact, core_resolved_fact] }

      before do
        legacy_resolved_fact.user_query = 'operatingsystem'
        legacy_resolved_fact.filter_tokens = []

        core_resolved_fact.user_query = 'os.name'
        core_resolved_fact.filter_tokens = []
      end

      it 'returns one fact' do
        Facter::FactFilter.new.filter_facts!(searched_facts)
        expect(searched_facts.size).to eq(1)
      end

      it 'return only core fact' do
        Facter::FactFilter.new.filter_facts!(searched_facts)
        expect(searched_facts.first.type).to eq(:core)
      end

      it 'returns core and legacy facts' do
        allow(Facter::Options).to receive(:[]).with(:show_legacy).and_return(true)
        Facter::FactFilter.new.filter_facts!(searched_facts)
        expect(searched_facts.size).to eq(2)
      end
    end
  end

  it 'filters value inside fact when value is array' do
    fact_value = { full: '18.7.0', major: '18', minor: 7, arry: ['val', { val2: 'val3' }] }
    resolved_fact = Facter::ResolvedFact.new('os.release', fact_value)

    resolved_fact.user_query = 'os.release.arry.1.val2'
    resolved_fact.filter_tokens = ['arry', 1, 'val2']

    Facter::FactFilter.new.filter_facts!([resolved_fact])

    expect(resolved_fact.value).to eq('val3')
  end
end
