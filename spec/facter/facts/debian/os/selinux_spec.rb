# frozen_string_literal: true

describe Facts::Debian::Os::Selinux do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.selinux', value: { enabled: 'value' })
      allow(Facter::Resolvers::SELinux).to receive(:resolve).with(:enabled).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.selinux', enabled: 'value').and_return(expected_fact)

      fact = Facts::Debian::Os::Selinux.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
