# frozen_string_literal: true

describe Facts::Openbsd::Netmask6Interfaces do
  subject(:fact) { Facts::Openbsd::Netmask6Interfaces.new }

  before do
    allow(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
  end

  describe '#call_the_resolver' do
    let(:interfaces) do
      { 'em0' => { netmask6: 'fe80::99bf:da20:ad3:9bfe' },
        'vio0' => { netmask6: 'fe80::99bf:da20:ad3:9bfe' } }
    end

    it 'calls Facter::Resolvers::NetworkingOpenBSD' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'returns legacy facts with names netmask6_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'netmask6_em0',
                                                    value: interfaces['em0'][:netmask6], type: :legacy),
                        an_object_having_attributes(name: 'netmask6_vio0',
                                                    value: interfaces['vio0'][:netmask6], type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver return nil' do
    let(:interfaces) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and contain_exactly
    end
  end
end
