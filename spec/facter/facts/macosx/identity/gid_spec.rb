# frozen_string_literal: true

describe Facts::Macosx::Identity::Gid do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Identity::Gid.new }

    let(:value) { '20' }

    before do
      allow(Facter::Resolvers::PosxIdentity).to receive(:resolve).with(:gid).and_return(value)
    end

    it 'calls Facter::Resolvers::PosxIdentity' do
      fact.call_the_resolver
      expect(Facter::Resolvers::PosxIdentity).to have_received(:resolve).with(:gid)
    end

    it 'returns a fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'identity.gid', value: value)
    end
  end
end
