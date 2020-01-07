# frozen_string_literal: true

describe 'Macosx IdentityUser' do
  context '#call_the_resolver' do
    let(:value) { 'testUser' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'identity.user', value: value) }
    subject(:fact) { Facter::Macosx::IdentityUser.new }

    before do
      expect(Facter::Resolvers::PosxIdentity).to receive(:resolve).with(:user).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new).with('identity.user', value).and_return(expected_resolved_fact)
    end

    it 'returns identity.user fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
