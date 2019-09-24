# frozen_string_literal: true

describe 'Windows OsWindowsProductName' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.windows.product_name', value: 'value')
      allow(Facter::Resolvers::ProductRelease).to receive(:resolve).with(:product_name).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.windows.product_name', 'value').and_return(expected_fact)

      fact = Facter::Windows::OsWindowsProductName.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
