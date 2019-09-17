# frozen_string_literal: true

describe 'Windows Kernel' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelmajorversion', value: 'value')
      allow(KernelResolver).to receive(:resolve).with(:kernelmajorversion).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelmajorversion', 'value').and_return(expected_fact)

      fact = Facter::Windows::KernelMajorVersion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
