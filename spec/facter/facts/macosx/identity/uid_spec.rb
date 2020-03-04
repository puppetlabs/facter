# frozen_string_literal: true

describe Facts::Macosx::Identity::Uid do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Identity::Uid.new }

    let(:value) { '501' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'identity.uid', value: value) }

    before do
      expect(Facter::Resolvers::PosxIdentity).to receive(:resolve).with(:uid).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new).with('identity.uid', value).and_return(expected_resolved_fact)
    end

    it 'returns identity.uid fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
