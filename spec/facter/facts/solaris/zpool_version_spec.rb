# frozen_string_literal: true

describe Facter::Solaris::ZPoolVersion do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Solaris::ZPoolVersion.new }

    let(:version) { '5' }

    before do
      allow(Facter::Resolvers::Solaris::ZPool).to receive(:resolve).with(:zpool_version).and_return(version)
    end

    it 'calls Facter::Resolvers::Solaris::ZPool' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::ZPool).to have_received(:resolve).with(:zpool_version)
    end

    it 'returns the ZPool version fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'zpool_version', value: version)
    end
  end
end
