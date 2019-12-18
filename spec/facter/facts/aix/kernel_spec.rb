# frozen_string_literal: true

describe 'Aix Kernel' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernel', value: 'AIX')
      allow(Facter::Resolvers::OsLevel).to receive(:resolve).with(:kernel).and_return('AIX')
      allow(Facter::ResolvedFact).to receive(:new).with('kernel', 'AIX').and_return(expected_fact)

      fact = Facter::Aix::Kernel.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
