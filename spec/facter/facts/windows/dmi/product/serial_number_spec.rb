# frozen_string_literal: true

describe 'Windows DmiProductSerialNumber' do
  context '#call_the_resolver' do
    let(:value) { 'VMware-42 1a 0d 03 0a b7 98 28-78 98 5e 85 a0 ad 18 47' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'dmi.product.serial_number', value: value) }
    let(:resolved_legacy_fact) { double(Facter::ResolvedFact, name: 'serialnumber', value: value, type: :legacy) }
    subject(:fact) { Facter::Windows::DmiProductSerialNumber.new }

    before do
      allow(Facter::Resolvers::DMIBios).to receive(:resolve).with(:serial_number).and_return(value)
    end

    it 'calls Facter::Resolvers::DMIBios' do
      expect(Facter::Resolvers::DMIBios).to receive(:resolve).with(:serial_number)
      fact.call_the_resolver
    end

    it 'returns serial_number fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.product.serial_number', value: value),
                        an_object_having_attributes(name: 'serialnumber', value: value, type: :legacy))
    end
  end
end
