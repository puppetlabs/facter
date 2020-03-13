# frozen_string_literal: true

describe Facts::Macosx::Dmi::Product::Name do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Dmi::Product::Name.new }

    let(:value) { 'MacBookPro11,4' }

    before do
      allow(Facter::Resolvers::Macosx::DmiBios).to receive(:resolve).with(:macosx_model).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::DmiBios).to have_received(:resolve).with(:macosx_model)
    end

    it 'returns a fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.product.name', value: value),
                        an_object_having_attributes(name: 'productname', value: value, type: :legacy))
    end
  end
end
