# frozen_string_literal: true

describe Facts::Windows::MacaddressInterfaces do
  subject(:fact) { Facts::Windows::MacaddressInterfaces.new }

  before do
    allow(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
  end

  describe '#call_the_resolver' do
    let(:interfaces) { { 'eth0' => { mac: '10.16.117.100' }, 'en1' => { mac: '10.16.117.255' } } }

    it 'calls Facter::Resolvers::Networking' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'returns legacy facts with names macaddress_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'macaddress_eth0',
                                                    value: interfaces['eth0'][:mac], type: :legacy),
                        an_object_having_attributes(name: 'macaddress_en1',
                                                    value: interfaces['en1'][:mac], type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:interfaces) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and contain_exactly
    end
  end
end
