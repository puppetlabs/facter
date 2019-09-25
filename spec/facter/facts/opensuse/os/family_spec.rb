# frozen_string_literal: true

describe 'Opensuse OsFamily' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.family', value: 'Value')
      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:id).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.family', 'Value').and_return(expected_fact)

      fact = Facter::Opensuse::OsFamily.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
