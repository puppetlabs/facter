# frozen_string_literal: true

describe 'Fedora DmiBiosVersion' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = '6.00'
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.bios.version', value: value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_version).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.bios.version', value).and_return(expected_fact)

      fact = Facter::Fedora::DmiBiosVersion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
