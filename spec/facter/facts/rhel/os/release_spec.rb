# frozen_string_literal: true

describe 'Rhel OsRelease' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.release',
                                                   value: { full: 'value', major: 'value', minor: nil })
      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new)
        .with('os.release', full: 'value', major: 'value', minor: nil)
        .and_return(expected_fact)

      fact = Facter::Rhel::OsRelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
