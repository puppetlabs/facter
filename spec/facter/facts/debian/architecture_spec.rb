# frozen_string_literal: true

describe 'Debian OsArchitecture' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.architecture', value: 'value')
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:machine).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.architecture', 'value').and_return(expected_fact)

      fact = Facter::Debian::OsArchitecture.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end

    it 'returns a amd64 if resolver returns x86_64' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.architecture', value: 'amd64')
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:machine).and_return('x86_64')
      allow(Facter::ResolvedFact).to receive(:new).with('os.architecture', 'amd64').and_return(expected_fact)

      fact = Facter::Debian::OsArchitecture.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
