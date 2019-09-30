# frozen_string_literal: true

describe 'Debian OsSelinux' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.selinux', value: { enabled: 'true' })
      allow(Facter::Resolvers::SELinux).to receive(:resolve).with(:enabled).and_return('true')
      allow(Facter::ResolvedFact).to receive(:new).with('os.selinux', enabled: 'true').and_return(expected_fact)

      fact = Facter::Debian::OsSelinux.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
