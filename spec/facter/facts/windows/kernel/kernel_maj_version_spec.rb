# frozen_string_literal: true

describe 'Windows KernelMajVersion' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelmajversion', value: 'value')
      allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelmajorversion).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelmajversion', 'value').and_return(expected_fact)

      fact = Facter::Windows::KernelMajVersion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
