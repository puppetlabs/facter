# frozen_string_literal: true

describe Facts::Debian::Filesystems do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Filesystems.new }

    let(:value) { 'ext2,ext3,ext4,xfs' }

    before do
      allow(Facter::Resolvers::Linux::Filesystems).to \
        receive(:resolve).with(:systems).and_return(value)
    end

    it 'calls Facter::Resolvers::Linux::Filesystems' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Filesystems).to have_received(:resolve).with(:systems)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'filesystems', value: value)
    end
  end
end
