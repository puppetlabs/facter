# frozen_string_literal: true

describe 'Windows DmiProductUUID' do
  context '#call_the_resolver' do
    let(:value) { '030D1A42-B70A-2898-7898-5E85A0AD1847' }
    subject(:fact) { Facter::Windows::DmiProductUUID.new }

    before do
      allow(Facter::Resolvers::DMIComputerSystem).to receive(:resolve).with(:uuid).and_return(value)
    end

    it 'calls Facter::Resolvers::DMIComputerSystem' do
      expect(Facter::Resolvers::DMIComputerSystem).to receive(:resolve).with(:uuid)
      fact.call_the_resolver
    end

    it 'returns product uuid fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.product.uuid', value: value),
                        an_object_having_attributes(name: 'uuid', value: value, type: :legacy))
    end
  end
end
