# frozen_string_literal: true

describe Facts::Sles::Dmi::Manufacturer do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Dmi::Manufacturer.new }

    let(:sys_vendor) { 'VMware, Inc.' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:sys_vendor).and_return(sys_vendor)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:sys_vendor)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.manufacturer', value: sys_vendor),
                        an_object_having_attributes(name: 'manufacturer', value: sys_vendor, type: :legacy))
    end
  end
end
