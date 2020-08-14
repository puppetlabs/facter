# frozen_string_literal: true

describe Facts::Solaris::Dmi::Manufacturer do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Dmi::Manufacturer.new }

    let(:manufacturer) { 'VMware, Inc.' }

    before do
      allow(Facter::Resolvers::Uname).to \
        receive(:resolve).with(:processor).and_return(isa)
    end

    context 'when i386' do
      let(:isa) { 'i386' }

      before do
        allow(Facter::Resolvers::Solaris::Dmi).to \
          receive(:resolve).with(:manufacturer).and_return(manufacturer)
      end

      it 'calls Facter::Resolvers::Solaris::Dmi' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Solaris::Dmi).to have_received(:resolve).with(:manufacturer)
      end

      it 'returns manufacturer fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'dmi.manufacturer', value: manufacturer),
                          an_object_having_attributes(name: 'manufacturer', value: manufacturer, type: :legacy))
      end
    end

    context 'when sparc' do
      let(:isa) { 'sparc' }

      before do
        allow(Facter::Resolvers::Solaris::DmiSparc).to \
          receive(:resolve).with(:manufacturer).and_return(manufacturer)
      end

      it 'calls Facter::Resolvers::Solaris::DmiSparc' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Solaris::DmiSparc).to have_received(:resolve).with(:manufacturer)
      end

      it 'returns manufacturer fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'dmi.manufacturer', value: manufacturer),
                          an_object_having_attributes(name: 'manufacturer', value: manufacturer, type: :legacy))
      end
    end
  end
end
