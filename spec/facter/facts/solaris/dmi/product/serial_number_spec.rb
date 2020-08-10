# frozen_string_literal: true

describe Facts::Solaris::Dmi::Product::SerialNumber do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Dmi::Product::SerialNumber.new }

    let(:serial_number) { 'VMware-42 1a a9 29 31 8f fa e9-7d 69 2e 23 21 b0 0c 45' }

    before do
      allow(Facter::Resolvers::Uname).to \
        receive(:resolve).with(:processor).and_return(isa)
    end

    context 'when i386' do
      let(:isa) { 'i386' }

      before do
        allow(Facter::Resolvers::Solaris::Dmi).to \
          receive(:resolve).with(:serial_number).and_return(serial_number)
      end

      it 'calls Facter::Resolvers::Solaris::Dmi' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Solaris::Dmi).to have_received(:resolve).with(:serial_number)
      end

      it 'returns resolved facts' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'dmi.product.serial_number', value: serial_number),
                          an_object_having_attributes(name: 'serialnumber', value: serial_number, type: :legacy))
      end
    end

    context 'when sparc' do
      let(:isa) { 'sparc' }

      before do
        allow(Facter::Resolvers::Solaris::DmiSparc).to \
          receive(:resolve).with(:serial_number).and_return(serial_number)
      end

      it 'calls Facter::Resolvers::Solaris::DmiSparc' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Solaris::DmiSparc).to have_received(:resolve).with(:serial_number)
      end

      it 'returns resolved facts' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'dmi.product.serial_number', value: serial_number),
                          an_object_having_attributes(name: 'serialnumber', value: serial_number, type: :legacy))
      end
    end
  end
end
