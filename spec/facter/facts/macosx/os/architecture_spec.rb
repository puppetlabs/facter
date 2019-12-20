# frozen_string_literal: true

describe 'Macosx OsArchitecture' do
  context '#call_the_resolver' do
    let(:expected_fact) do
      [double(Facter::ResolvedFact, name: 'os.architecture', value: 'x86_64'),
       double(Facter::ResolvedFact, name: 'architecture', value: 'x86_64', type: :legacy)]
    end
    it 'returns a fact' do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:machine).and_return('x86_64')
      allow(Facter::ResolvedFact).to receive(:new).with('os.architecture', 'x86_64').and_return(expected_fact[0])
      allow(Facter::ResolvedFact).to receive(:new).with('architecture', 'x86_64', :legacy).and_return(expected_fact[1])

      fact = Facter::Macosx::OsArchitecture.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
