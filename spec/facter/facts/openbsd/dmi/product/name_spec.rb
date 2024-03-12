# frozen_string_literal: true

describe Facts::Openbsd::Dmi::Product::Name do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Openbsd::Dmi::Product::Name.new }

    let(:product_name) { 'VMM' }

    before do
      allow(Facter::Resolvers::Openbsd::DmiBios).to \
        receive(:resolve).with(:product_name).and_return(product_name)
    end

    it 'calls Facter::Resolvers::Openbsd::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Openbsd::DmiBios).to have_received(:resolve).with(:product_name)
    end

    it 'returns product name fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.product.name', value: product_name),
                        an_object_having_attributes(name: 'productname', value: product_name, type: :legacy))
    end
  end
end
