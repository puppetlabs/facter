# frozen_string_literal: true

describe 'Fedora DmiProductSerialNumber' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = 'VMware-42 1a a9 29 31 8f fa e9-7d 69 2e 23 21 b0 0c 45'
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.product.serial_number', value: value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_serial).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.product.serial_number', value).and_return(expected_fact)

      fact = Facter::El::DmiProductSerialNumber.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
