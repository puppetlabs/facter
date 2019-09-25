# frozen_string_literal: true

describe 'Opensuse OsRelease' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.release', value: 'Value')
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:release).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.release', 'value').and_return(expected_fact)

      fact = Facter::Opensuse::OsRelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
