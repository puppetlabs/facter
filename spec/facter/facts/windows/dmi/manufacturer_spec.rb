# frozen_string_literal: true

describe 'Windows DmiManufacturer' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.manufacturer', value: 'VMware, Inc.')
      allow(DMIBiosResolver).to receive(:resolve).with(:manufacturer).and_return('VMware, Inc.')
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.manufacturer', 'VMware, Inc.').and_return(expected_fact)

      fact = Facter::Windows::DmiManufacturer.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
