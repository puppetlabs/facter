# frozen_string_literal: true

describe Facts::Linux::Dmi::Product::Uuid do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Dmi::Product::Uuid.new }

    let(:product_uuid) { '421aa929-318f-fae9-7d69-2e2321b00c45' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:product_uuid).and_return(product_uuid)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:product_uuid)
    end

    it 'returns resolved facts' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.product.uuid', value: product_uuid),
                        an_object_having_attributes(name: 'uuid', value: product_uuid, type: :legacy))
    end
  end
end
