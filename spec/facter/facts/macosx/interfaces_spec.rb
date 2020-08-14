# frozen_string_literal: true

describe Facts::Macosx::Interfaces do
  subject(:fact) { Facts::Macosx::Interfaces.new }

  before do
    allow(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
  end

  describe '#call_the_resolver' do
    let(:interfaces) { { en1: { ip: '192.168.1.6' }, llw0: { ip: '192.168.1.3' } } }
    let(:interfaces_names) { 'en1,llw0' }

    it 'calls Facter::Resolvers::Networking' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'returns interfaces names' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'interfaces', value: interfaces_names, type: :legacy)
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:interfaces) { nil }
    let(:interfaces_names) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'interfaces', value: interfaces_names, type: :legacy)
    end
  end
end
