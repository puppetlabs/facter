# frozen_string_literal: true

describe 'Windows OsWindowsSystem32' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.windows.system32', value: 'value')
      allow(Facter::Resolvers::System32Resolver).to receive(:resolve).with(:system32).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.windows.system32', 'value').and_return(expected_fact)

      fact = Facter::Windows::OsWindowsSystem32.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
