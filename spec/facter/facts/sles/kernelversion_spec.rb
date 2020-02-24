# frozen_string_literal: true

describe Facter::Sles::Kernelversion do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelversion', value: '3.12.49')
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return('3.12.49-11-default')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelversion', '3.12.49').and_return(expected_fact)

      fact = Facter::Sles::Kernelversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
