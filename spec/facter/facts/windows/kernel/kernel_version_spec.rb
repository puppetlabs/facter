# frozen_string_literal: true

describe 'Windows KernelVersion' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelversion', value: 'value')
      allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelversion).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelversion', 'value').and_return(expected_fact)

      fact = Facter::Windows::KernelVersion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
