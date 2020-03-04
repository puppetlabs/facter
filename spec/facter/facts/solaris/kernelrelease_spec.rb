# frozen_string_literal: true

describe Facts::Solaris::Kernelrelease do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelrelease', value: '5.11')
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return('5.11')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelrelease', '5.11').and_return(expected_fact)

      fact = Facts::Solaris::Kernelrelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
