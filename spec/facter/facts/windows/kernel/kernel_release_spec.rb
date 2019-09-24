# frozen_string_literal: true

describe 'Windows KernelRelease' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelrelease', value: 'value')
      allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelversion).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelrelease', 'value').and_return(expected_fact)

      fact = Facter::Windows::KernelRelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
