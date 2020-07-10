# frozen_string_literal: true

describe Facts::Linux::NetworkInterfaces do
  subject(:fact) { Facts::Linux::NetworkInterfaces.new }

  before do
    allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:interfaces).and_return(interfaces)
  end

  describe '#call_the_resolver' do
    let(:interfaces) { { 'eth0' => { network: '10.255.255.255' }, 'en1' => { network: '10.17.255.255' } } }

    it 'calls Facter::Resolvers::NetworkingLinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:interfaces)
    end

    it 'returns legacy facts with names network_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'network_eth0',
                                                    value: interfaces['eth0'][:network], type: :legacy),
                        an_object_having_attributes(name: 'network_en1',
                                                    value: interfaces['en1'][:network], type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:interfaces) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and contain_exactly
    end
  end
end
