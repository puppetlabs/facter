# frozen_string_literal: true

describe 'Fedora DmiBiosVendor' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = 'Phoenix Technologies LTD'
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.bios.vendor', value: value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.bios.vendor', value).and_return(expected_fact)

      fact = Facter::El::DmiBiosVendor.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
