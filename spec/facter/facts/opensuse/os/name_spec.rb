# frozen_string_literal: true

describe 'Opensuse OsName' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.name', value: 'Value')
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:distributor_id).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.name', 'value').and_return(expected_fact)

      fact = Facter::Opensuse::OsName.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
