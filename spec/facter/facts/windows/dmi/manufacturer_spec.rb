# frozen_string_literal: true

describe 'Windows DmiManufacturer' do
  context '#call_the_resolver' do
    let(:value) { 'VMware, Inc.' }
    subject(:fact) { Facter::Windows::DmiManufacturer.new }

    before do
      allow(Facter::Resolvers::DMIBios).to receive(:resolve).with(:manufacturer).and_return(value)
    end

    it 'calls Facter::Resolvers::DMIBios' do
      expect(Facter::Resolvers::DMIBios).to receive(:resolve).with(:manufacturer)
      fact.call_the_resolver
    end

    it 'returns manufacturer fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.manufacturer', value: value),
                        an_object_having_attributes(name: 'manufacturer', value: value, type: :legacy))
    end
  end
end
