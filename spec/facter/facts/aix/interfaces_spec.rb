# frozen_string_literal: true

describe Facts::Aix::Interfaces do
  subject(:fact) { Facts::Aix::Interfaces.new }

  before do
    allow(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
  end

  describe '#call_the_resolver' do
    let(:interfaces) { { 'eth0' => { ip6: 'fe80::99bf:da20:ad3:9bfe' }, 'en1' => { ip6: 'fe80::99bf:da20:ad3:9bfe' } } }

    it 'calls Facter::Resolvers::Aix::Networking' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'returns interfaces names' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'interfaces', value: interfaces.keys.sort.join(','), type: :legacy)
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:interfaces) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'interfaces', value: interfaces, type: :legacy)
    end
  end
end
