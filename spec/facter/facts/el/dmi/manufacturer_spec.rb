# frozen_string_literal: true

describe 'Fedora DmiManufacturer' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = 'VMware, Inc.'
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.manufacturer', value: value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:sys_vendor).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.manufacturer', value).and_return(expected_fact)

      fact = Facter::El::DmiManufacturer.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
