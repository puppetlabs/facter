# frozen_string_literal: true

describe Facts::Macosx::Identity::Privileged do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Identity::Privileged.new }

    let(:value) { 'false' }

    before do
      allow(Facter::Resolvers::PosxIdentity).to receive(:resolve).with(:privileged).and_return(value)
    end

    it 'returns identity privileged fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'identity.privileged', value: value)
    end
  end
end
