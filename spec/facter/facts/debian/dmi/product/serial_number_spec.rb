# frozen_string_literal: true

describe Facts::Debian::Dmi::Product::SerialNumber do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Dmi::Product::SerialNumber.new }

    let(:serial_number) { 'VMware-42 1a a9 29 31 8f fa e9-7d 69 2e 23 21 b0 0c 45' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:product_serial).and_return(serial_number)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:product_serial)
    end

    it 'returns product serial number fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'dmi.product.serial_number', value: serial_number)
    end
  end
end
