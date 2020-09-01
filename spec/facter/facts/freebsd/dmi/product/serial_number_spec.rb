# frozen_string_literal: true

describe Facts::Freebsd::Dmi::Product::SerialNumber do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Dmi::Product::SerialNumber.new }

    let(:serial_number) { 'VMware-42 1a a9 29 31 8f fa e9-7d 69 2e 23 21 b0 0c 45' }

    before do
      allow(Facter::Resolvers::Freebsd::DmiBios).to \
        receive(:resolve).with(:product_serial).and_return(serial_number)
    end

    it 'calls Facter::Resolvers::Freebsd::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Freebsd::DmiBios).to have_received(:resolve).with(:product_serial)
    end

    it 'returns resolved facts' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.product.serial_number', value: serial_number),
                        an_object_having_attributes(name: 'serialnumber', value: serial_number, type: :legacy))
    end
  end
end
