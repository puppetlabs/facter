# frozen_string_literal: true

describe 'Windows OsWindowsProductName' do
  context '#call_the_resolver' do
    let(:value) { 'Windows Server 2016 Standard' }
    subject(:fact) { Facter::Windows::OsWindowsProductName.new }

    before do
      allow(Facter::Resolvers::ProductRelease).to receive(:resolve).with(:product_name).and_return(value)
    end

    it 'calls Facter::Resolvers::ProductRelease' do
      expect(Facter::Resolvers::ProductRelease).to receive(:resolve).with(:product_name)
      fact.call_the_resolver
    end

    it 'returns os product name fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.windows.product_name', value: value),
                        an_object_having_attributes(name: 'windows_product_name', value: value, type: :legacy))
    end
  end
end
