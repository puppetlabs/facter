# frozen_string_literal: true

describe Facts::Macosx::Networking::Netmask6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Networking::Netmask6.new }

    let(:value) { 'ffff:ffff:ffff:ffff::' }
    let(:primary_interface) { 'en0' }
    let(:interfaces) do
      { 'en0' => { mac: '64:5a:ed:ea:5c:81:',
                   bindings6: [{ address: 'fe80::2cba:e4ff:fe83:4bb7',
                                 netmask: 'ffff:ffff:ffff:ffff::',
                                 network: 'fe80::' }] } }
    end

    before do
      allow(Facter::Resolvers::Macosx::Networking)
        .to receive(:resolve).with(:primary_interface).and_return(primary_interface)
      allow(Facter::Resolvers::Macosx::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
    end

    it 'calls Facter::Resolvers::Macosx::Networking with :primary_interface' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Networking).to have_received(:resolve).with(:primary_interface)
    end

    it 'calls Facter::Resolvers::Macosx::Networking with :interfaces' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'returns the netmask6 fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.netmask6', value: value),
                        an_object_having_attributes(name: 'netmask6', value: value, type: :legacy))
    end

    context 'when primary interface can not be retrieved' do
      let(:primary_interface) { nil }
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.netmask6', value: value),
                          an_object_having_attributes(name: 'netmask6', value: value, type: :legacy))
      end
    end

    context 'when interfaces can not be retrieved' do
      let(:interfaces) { nil }
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver[0].value).to be(value)
      end
    end

    context 'when primary interface does not have ipv6' do
      let(:interfaces) do
        { 'en0' => { mac: '64:5a:ed:ea:5c:81:',
                     bindings: [{ address: '10.0.0.1', netmask: '255.255.255.0', network: '192.168.143.0' }] } }
      end
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver[0].value).to be(value)
      end
    end
  end
end
