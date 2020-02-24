# frozen_string_literal: true

describe Facter::Solaris::Kernelversion do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelversion', value: '11.4.0.15.0')
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelversion).and_return('11.4.0.15.0')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelversion', '11.4.0.15.0').and_return(expected_fact)

      fact = Facter::Solaris::Kernelversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
