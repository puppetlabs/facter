# frozen_string_literal: true

describe Facter::FactFilter do
  describe '#filter_facts!' do
    context 'when legacy facts are blocked' do
      let(:fact_value) { 'value_1' }
      let(:resolved_fact) { Facter::ResolvedFact.new('my_fact', fact_value, :legacy) }

      before do
        allow(Facter::Options).to receive(:[])
        allow(Facter::Options).to receive(:[]).with(:show_legacy).and_return(false)
      end

      it 'filters blocked legacy facts' do
        fact_filter_input = [resolved_fact]
        Facter::FactFilter.new.filter_facts!(fact_filter_input, [])
        expect(fact_filter_input).to eq([])
      end

      context 'when user_query is provided' do
        it 'does not filter out the requested fact' do
          fact_filter_input = [resolved_fact]
          result = Facter::FactFilter.new.filter_facts!([resolved_fact], ['my_fact'])
          expect(result).to eql(fact_filter_input)
        end
      end
    end
  end
end
