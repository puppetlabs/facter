# frozen_string_literal: true

describe Facts::Openbsd::Dmi::Product::SerialNumber do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Openbsd::Dmi::Product::SerialNumber.new }

    context 'when resolver returns serial number' do
      let(:serial_number) { '17425315' }

      before do
        allow(Facter::Resolvers::Openbsd::DmiBios).to \
          receive(:resolve).with(:product_serial).and_return(serial_number)
      end

      it 'calls Facter::Resolvers::Openbsd::DmiBios' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Openbsd::DmiBios).to have_received(:resolve).with(:product_serial)
      end

      it 'returns resolved facts' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'dmi.product.serial_number', value: serial_number),
                          an_object_having_attributes(name: 'serialnumber', value: serial_number, type: :legacy))
      end
    end

    context 'when resolver returns nil' do
      before do
        allow(Facter::Resolvers::Openbsd::DmiBios).to \
          receive(:resolve).with(:product_serial).and_return(nil)
      end

      it 'returns serial information' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'dmi.product.serial_number', value: nil),
                          an_object_having_attributes(name: 'serialnumber', value: nil, type: :legacy))
      end
    end
  end
end
