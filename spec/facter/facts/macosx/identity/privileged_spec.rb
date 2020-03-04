# frozen_string_literal: true

describe Facts::Macosx::Identity::Privileged do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Identity::Privileged.new }

    let(:value) { 'false' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'identity.privileged', value: value) }

    before do
      expect(Facter::Resolvers::PosxIdentity).to receive(:resolve)
        .with(:privileged)
        .and_return(value)

      expect(Facter::ResolvedFact).to receive(:new)
        .with('identity.privileged', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns identity.privileged fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
