# frozen_string_literal: true

describe Facts::Aix::Networking::Netmask do
  subject(:fact) { Facts::Aix::Networking::Netmask.new }

  before do
    allow(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:netmask).and_return(value)
  end

  describe '#call_the_resolver' do
    let(:value) { '10.16.122.163' }

    it 'calls Facter::Resolvers::Aix::Networking with netmask' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Networking).to have_received(:resolve).with(:netmask)
    end

    it 'returns netmask fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array)
        .and contain_exactly(an_object_having_attributes(name: 'networking.netmask', value: value),
                             an_object_having_attributes(name: 'netmask', value: value, type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:value) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array)
        .and contain_exactly(an_object_having_attributes(name: 'networking.netmask', value: nil),
                             an_object_having_attributes(name: 'netmask', value: nil, type: :legacy))
    end
  end
end
