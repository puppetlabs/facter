# frozen_string_literal: true

describe 'Windows DmiProductName' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::Fact, name: 'dmi.product.name', value: 'value')
      allow(DMIComputerSystemResolver).to receive(:resolve).with(:name).and_return('value')
      allow(Facter::Fact).to receive(:new).with('dmi.product.name', 'value').and_return(expected_fact)

      fact = Facter::Windows::DmiProductName.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
