# frozen_string_literal: true

describe 'Ubuntu OsSelinux' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.selinux', value: { enabled: 'value' })
      allow(Facter::Resolvers::SELinux).to receive(:resolve).with(:enabled).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.selinux', enabled: 'value').and_return(expected_fact)

      fact = Facter::Debian::OsSelinux.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
