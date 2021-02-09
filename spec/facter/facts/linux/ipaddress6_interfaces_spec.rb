# frozen_string_literal: true

describe Facts::Linux::Ipaddress6Interfaces do
  subject(:fact) { Facts::Linux::Ipaddress6Interfaces.new }

  before do
    allow(Facter::Resolvers::Linux::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
  end

  describe '#call_the_resolver' do
    let(:interfaces) { { 'eth0' => { ip6: 'fe80::99bf:da20:ad3:9bfe' }, 'en1' => { ip6: 'fe80::99bf:da20:ad3:9bfe' } } }

    it 'calls Facter::Resolvers::NetworkingLinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'returns legacy facts with names ipaddress6_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'ipaddress6_eth0',
                                                    value: interfaces['eth0'][:ip6], type: :legacy),
                        an_object_having_attributes(name: 'ipaddress6_en1',
                                                    value: interfaces['en1'][:ip6], type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:interfaces) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and contain_exactly
    end
  end
end
