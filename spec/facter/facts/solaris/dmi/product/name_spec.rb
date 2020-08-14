# frozen_string_literal: true

describe Facts::Solaris::Dmi::Product::Name do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Dmi::Product::Name.new }

    let(:product_name) { 'VMware Virtual Platform' }

    before do
      allow(Facter::Resolvers::Uname).to \
        receive(:resolve).with(:processor).and_return(isa)
    end

    context 'when i386' do
      let(:isa) { 'i386' }

      before do
        allow(Facter::Resolvers::Solaris::Dmi).to \
          receive(:resolve).with(:product_name).and_return(product_name)
      end

      it 'calls Facter::Resolvers::Solaris::Dmi' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Solaris::Dmi).to have_received(:resolve).with(:product_name)
      end

      it 'returns product name fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'dmi.product.name', value: product_name),
                          an_object_having_attributes(name: 'productname', value: product_name, type: :legacy))
      end
    end

    context 'when sparc' do
      let(:isa) { 'sparc' }

      before do
        allow(Facter::Resolvers::Solaris::DmiSparc).to \
          receive(:resolve).with(:product_name).and_return(product_name)
      end

      it 'calls Facter::Resolvers::Solaris::DmiSparc' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Solaris::DmiSparc).to have_received(:resolve).with(:product_name)
      end

      it 'returns product name fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'dmi.product.name', value: product_name),
                          an_object_having_attributes(name: 'productname', value: product_name, type: :legacy))
      end
    end
  end
end
