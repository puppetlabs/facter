# frozen_string_literal: true

describe Facter::El::DmiProductUuid do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      value = '421aa929-318f-fae9-7d69-2e2321b00c45'
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.product.uuid', value: value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_uuid).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.product.uuid', value).and_return(expected_fact)

      fact = Facter::El::DmiProductUuid.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
