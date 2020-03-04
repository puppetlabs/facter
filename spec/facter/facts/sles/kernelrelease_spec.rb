# frozen_string_literal: true

describe Facts::Sles::Kernelrelease do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelrelease', value: '3.12.49-11-default')
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return('3.12.49-11-default')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelrelease', '3.12.49-11-default').and_return(expected_fact)

      fact = Facts::Sles::Kernelrelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
