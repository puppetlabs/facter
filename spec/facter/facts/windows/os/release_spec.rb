# frozen_string_literal: true

describe 'Windows OsRelease' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.release', value: { full: 'value', major: 'value' })
      allow(Facter::Resolvers::WinOsReleaseResolver).to receive(:resolve).with(:full).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.release', full: 'value', major: 'value')
                                                  .and_return(expected_fact)

      fact = Facter::Windows::OsRelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
