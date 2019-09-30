# frozen_string_literal: true

describe 'Sles OsRelease' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.release', value: { full: '10.0', major: '10', minor: 0 })
      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return('10')
      allow(Facter::ResolvedFact).to receive(:new)
        .with('os.release', full: '10.0', major: '10', minor: 0)
        .and_return(expected_fact)

      fact = Facter::Sles::OsRelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
