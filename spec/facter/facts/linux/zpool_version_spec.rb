# frozen_string_literal: true

describe Facts::Linux::ZpoolVersion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::ZpoolVersion.new }

    let(:version) { '5' }

    before do
      allow(Facter::Resolvers::Zpool).to receive(:resolve).with(:zpool_version).and_return(version)
    end

    it 'returns the ZPool version fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'zpool_version', value: version)
    end
  end
end
