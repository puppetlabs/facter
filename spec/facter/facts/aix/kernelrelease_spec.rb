# frozen_string_literal: true

describe Facter::Aix::Kernelrelease do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelrelease', value: '6100-09-00-0000')
      allow(Facter::Resolvers::OsLevel).to receive(:resolve).with(:build).and_return('6100-09-00-0000')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelrelease', '6100-09-00-0000').and_return(expected_fact)

      fact = Facter::Aix::Kernelrelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
