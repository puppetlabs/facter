# frozen_string_literal: true

describe 'Windows DmiProductUUID' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::Fact, name: 'dmi.product.uuid', value: 'value')
      allow(DMIComputerSystemResolver).to receive(:resolve).with(:uuid).and_return('value')
      allow(Facter::Fact).to receive(:new).with('dmi.product.uuid', 'value').and_return(expected_fact)

      fact = Facter::Windows::DmiProductUUID.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
