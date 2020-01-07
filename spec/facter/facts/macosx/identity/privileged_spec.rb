# frozen_string_literal: true

describe 'Macosx IdentityPrivileged' do
  context '#call_the_resolver' do
    let(:value) { 'false' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'identity.privileged', value: value) }
    subject(:fact) { Facter::Macosx::IdentityPrivileged.new }

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
