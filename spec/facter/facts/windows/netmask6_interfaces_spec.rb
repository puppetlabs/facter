# frozen_string_literal: true

describe 'Windows Netmask6Interfaces' do
  subject(:fact) { Facter::Windows::Netmask6Interfaces.new }

  before do
    allow(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
  end

  context '#call_the_resolver' do
    let(:interfaces) do
      { 'eth0' => { netmask6: 'fe80::99bf:da20:ad3:9bfe' },
        'en1' => { netmask6: 'fe80::99bf:da20:ad3:9bfe' } }
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces)
      fact.call_the_resolver
    end

    it 'returns legacy facts with names netmask6_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'netmask6_eth0',
                                                    value: interfaces['eth0'][:netmask6], type: :legacy),
                        an_object_having_attributes(name: 'netmask6_en1',
                                                    value: interfaces['en1'][:netmask6], type: :legacy))
    end
  end

  context '#call_the_resolver when resolver return nil' do
    let(:interfaces) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and contain_exactly
    end
  end
end
