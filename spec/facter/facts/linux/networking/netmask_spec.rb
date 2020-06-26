# frozen_string_literal: true

describe Facts::Linux::Networking::Netmask do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Networking::Netmask.new }

    let(:value) { '10.16.122.163' }

    before do
      allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:netmask).and_return(value)
    end

    it 'calls Facter::Resolvers::NetworkingLinux with netmask' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:netmask)
    end

    it 'returns netmask fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array)
        .and contain_exactly(an_object_having_attributes(name: 'networking.netmask', value: value),
                             an_object_having_attributes(name: 'netmask', value: value, type: :legacy))
    end

    context 'when netmask can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.netmask', value: value),
                          an_object_having_attributes(name: 'netmask', value: value, type: :legacy))
      end
    end
  end
end
