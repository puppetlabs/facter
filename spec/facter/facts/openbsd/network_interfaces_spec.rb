# frozen_string_literal: true

describe Facts::Openbsd::NetworkInterfaces do
  subject(:fact) { Facts::Openbsd::NetworkInterfaces.new }

  before do
    allow(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
  end

  describe '#call_the_resolver' do
    let(:interfaces) { { 'em0' => { network: '10.255.255.255' }, 'vio0' => { network: '10.17.255.255' } } }

    it 'calls Facter::Resolvers::NetworkingOpenBSD' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'returns legacy facts with names network_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'network_em0',
                                                    value: interfaces['em0'][:network], type: :legacy),
                        an_object_having_attributes(name: 'network_vio0',
                                                    value: interfaces['vio0'][:network], type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:interfaces) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and contain_exactly
    end
  end
end
