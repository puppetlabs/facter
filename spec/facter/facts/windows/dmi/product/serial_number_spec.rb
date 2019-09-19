# frozen_string_literal: true

describe 'Windows DmiProductSerialNumber' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.product.serial_number', value: 'value')
      allow(DMIBiosResolver).to receive(:resolve).with(:serial_number).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.product.serial_number', 'value').and_return(expected_fact)

      fact = Facter::Windows::DmiProductSerialNumber.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
