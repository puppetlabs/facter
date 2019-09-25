# frozen_string_literal: true

describe 'Windows IsVirtual' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'is_virtual', value: 'value')
      allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:is_virtual).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('is_virtual', 'value').and_return(expected_fact)

      fact = Facter::Windows::IsVirtual.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
