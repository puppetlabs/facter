# frozen_string_literal: true

describe Facts::Aix::Networking::Scope6 do
  subject(:fact) { Facts::Aix::Networking::Scope6.new }

  before do
    allow(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:scope6).and_return(value)
  end

  describe '#call_the_resolver' do
    let(:value) { 'link' }

    it 'calls Facter::Resolvers::Aix::Networking with scope6' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Networking).to have_received(:resolve).with(:scope6)
    end

    it 'returns scope6 fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.scope6', value: value)
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:value) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.scope6', value: nil)
    end
  end
end
