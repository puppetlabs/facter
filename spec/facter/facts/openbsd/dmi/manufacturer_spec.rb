# frozen_string_literal: true

describe Facts::Openbsd::Dmi::Manufacturer do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Openbsd::Dmi::Manufacturer.new }

    let(:sys_vendor) { 'OpenBSD' }

    before do
      allow(Facter::Resolvers::Openbsd::DmiBios).to \
        receive(:resolve).with(:sys_vendor).and_return(sys_vendor)
    end

    it 'calls Facter::Resolvers::Openbsd::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Openbsd::DmiBios).to have_received(:resolve).with(:sys_vendor)
    end

    it 'returns manufacturer fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.manufacturer', value: sys_vendor),
                        an_object_having_attributes(name: 'manufacturer', value: sys_vendor, type: :legacy))
    end
  end
end
