# frozen_string_literal: true

describe Facts::Freebsd::Identity::Gid do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Identity::Gid.new }

    let(:value) { '20' }

    before do
      allow(Facter::Resolvers::PosxIdentity).to receive(:resolve).with(:gid).and_return(value)
    end

    it 'returns identity gid fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'identity.gid', value: value)
    end
  end
end
