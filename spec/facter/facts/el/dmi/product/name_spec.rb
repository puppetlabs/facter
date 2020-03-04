# frozen_string_literal: true

describe Facts::El::Dmi::Product::Name do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::El::Dmi::Product::Name.new }

    let(:product_name) { 'VMware Virtual Platform' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:product_name).and_return(product_name)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:product_name)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'dmi.product.name', value: product_name)
    end
  end
end
