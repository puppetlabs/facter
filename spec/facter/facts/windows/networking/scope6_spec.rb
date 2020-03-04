# frozen_string_literal: true

describe Facts::Windows::Networking::Scope6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Networking::Scope6.new }

    let(:value) { 'link' }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:scope6).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Networking).to receive(:resolve).with(:scope6)
      fact.call_the_resolver
    end

    it 'returns scope for ipv6 address' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'networking.scope6', value: value)
    end
  end
end
