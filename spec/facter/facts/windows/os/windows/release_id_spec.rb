# frozen_string_literal: true

describe 'Windows OsWindowsReleaseID' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.windows.release_id', value: 'value')
      allow(Facter::Resolvers::ProductReleaseResolver).to receive(:resolve).with(:release_id).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.windows.release_id', 'value').and_return(expected_fact)

      fact = Facter::Windows::OsWindowsReleaseID.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
