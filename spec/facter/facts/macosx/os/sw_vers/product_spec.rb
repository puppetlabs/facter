# frozen_string_literal: true

describe Facter::Macosx::OsMacosxProduct do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.macosx.product', value: 'value')
      allow(Facter::Resolvers::SwVers).to receive(:resolve).with(:productname).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.macosx.product', 'value').and_return(expected_fact)

      fact = Facter::Macosx::OsMacosxProduct.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
