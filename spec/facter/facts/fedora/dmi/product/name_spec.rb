# frozen_string_literal: true

describe 'Fedora DmiProductName' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = 'VMware Virtual Platform'
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.product.name', value: value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.product.name', value).and_return(expected_fact)

      fact = Facter::Fedora::DmiProductName.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
