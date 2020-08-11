# frozen_string_literal: true

describe Facts::Freebsd::Dmi::Bios::Vendor do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Dmi::Bios::Vendor.new }

    let(:vendor) { 'Phoenix Technologies LTD' }

    before do
      allow(Facter::Resolvers::Freebsd::DmiBios).to \
        receive(:resolve).with(:bios_vendor).and_return(vendor)
    end

    it 'calls Facter::Resolvers::Freebsd::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Freebsd::DmiBios).to have_received(:resolve).with(:bios_vendor)
    end

    it 'returns bios vendor fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.bios.vendor', value: vendor),
                        an_object_having_attributes(name: 'bios_vendor', value: vendor, type: :legacy))
    end
  end
end
