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

    context 'with legacy fact that should be blocked' do
      let(:fact_value) { 'value_1' }
      let(:resolved_fact) { Facter::ResolvedFact.new('my_fact', fact_value, :legacy) }

      before do
        resolved_fact.user_query = ''
        resolved_fact.filter_tokens = []
        allow(Facter::Options).to receive(:[]).with(:blocked_facts).and_return(['my_fact'])
        allow(Facter::Options).to receive(:[]).with(:show_legacy).and_return(true)
        allow(Facter::Options).to receive(:[]).with(:user_query).and_return('')
      end

      it 'filters blocked legacy facts' do
        fact_filter_input = [resolved_fact]
        Facter::FactFilter.new.filter_facts!(fact_filter_input)
        expect(fact_filter_input).to eq([])
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
