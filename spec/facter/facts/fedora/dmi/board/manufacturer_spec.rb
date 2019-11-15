# frozen_string_literal: true

describe 'Fedora DmiBoardManufacturer' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = 'Intel Corporation'
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.board.manufacturer', value: value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:board_vendor).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.board.manufacturer', value).and_return(expected_fact)

      fact = Facter::Fedora::DmiBoardManufacturer.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
