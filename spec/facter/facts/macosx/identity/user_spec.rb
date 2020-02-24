# frozen_string_literal: true

describe Facter::Macosx::IdentityUser do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Macosx::IdentityUser.new }

    let(:value) { 'testUser' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'identity.user', value: value) }

    before do
      expect(Facter::Resolvers::PosxIdentity).to receive(:resolve).with(:user).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new).with('identity.user', value).and_return(expected_resolved_fact)
    end

    it 'returns identity.user fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
