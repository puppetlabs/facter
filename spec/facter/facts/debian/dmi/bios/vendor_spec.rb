# frozen_string_literal: true

describe Facter::Debian::DmiBiosVendor do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Debian::DmiBiosVendor.new }

    let(:vendor) { 'Phoenix Technologies LTD' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:bios_vendor).and_return(vendor)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:bios_vendor)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'dmi.bios.vendor', value: vendor)
    end
  end
end
