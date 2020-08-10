# frozen_string_literal: true

describe Facts::Solaris::Dmi::Product::Uuid do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Dmi::Product::Uuid.new }

    let(:product_uuid) { '421aa929-318f-fae9-7d69-2e2321b00c45' }

    before do
      allow(Facter::Resolvers::Solaris::Dmi).to \
        receive(:resolve).with(:product_uuid).and_return(product_uuid)
      allow(Facter::Resolvers::Uname).to \
        receive(:resolve).with(:processor).and_return('i386')
    end

    it 'calls Facter::Resolvers::Solaris::Dmi' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Dmi).to have_received(:resolve).with(:product_uuid)
    end

    it 'returns resolved facts' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.product.uuid', value: product_uuid),
                        an_object_having_attributes(name: 'uuid', value: product_uuid, type: :legacy))
    end
  end
end
