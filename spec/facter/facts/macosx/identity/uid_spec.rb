# frozen_string_literal: true

describe Facts::Macosx::Identity::Uid do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Identity::Uid.new }

    let(:value) { '501' }

    before do
      allow(Facter::Resolvers::PosxIdentity).to receive(:resolve).with(:uid).and_return(value)
    end

    it 'calls Facter::Resolvers::PosxIdentity' do
      fact.call_the_resolver
      expect(Facter::Resolvers::PosxIdentity).to have_received(:resolve).with(:uid)
    end

    it 'returns a fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'identity.uid', value: value)
    end
  end
end
