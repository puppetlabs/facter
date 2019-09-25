# frozen_string_literal: true

describe 'Solaris OsArchitecture' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.architecture', value: 'i86pc')
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:machine).and_return('i86pc')
      allow(Facter::ResolvedFact).to receive(:new).with('os.architecture', 'i86pc').and_return(expected_fact)

      fact = Facter::Solaris::OsArchitecture.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
