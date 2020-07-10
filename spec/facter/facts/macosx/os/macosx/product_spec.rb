# frozen_string_literal: true

describe Facts::Macosx::Os::Macosx::Product do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Os::Macosx::Product.new }

    let(:product) { 'Mac OS X' }

    before do
      allow(Facter::Resolvers::SwVers).to \
        receive(:resolve).with(:productname).and_return(product)
    end

    it 'calls Facter::Resolvers::SwVers' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SwVers).to have_received(:resolve).with(:productname)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.macosx.product', value: product),
                        an_object_having_attributes(name: 'macosx_productname', value: product, type: :legacy))
    end
  end
end
