# frozen_string_literal: true

describe 'Windows OsWindowsInstallationType' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.windows.installation_type', value: 'value')
      allow(Facter::Resolvers::ProductReleaseResolver).to receive(:resolve).with(:installation_type).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.windows.installation_type', 'value')
                                                  .and_return(expected_fact)

      fact = Facter::Windows::OsWindowsInstallationType.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
