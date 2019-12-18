# frozen_string_literal: true

describe 'FactFilter' do
  describe '#filter_facts!' do
    context 'value is a hash' do
      context 'hash keys are symbols' do
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

      context 'hash keys are strings and symbols' do
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

    context 'value is a string' do
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
  end
end
