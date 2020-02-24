# frozen_string_literal: true

describe Facter::El::DmiBoardProduct do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      value = '440BX Desktop Reference Platform'
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.board.product', value: value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:board_name).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.board.product', value).and_return(expected_fact)

      fact = Facter::El::DmiBoardProduct.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
