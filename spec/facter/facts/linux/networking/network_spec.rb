# frozen_string_literal: true

describe Facts::Linux::Networking::Network do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Networking::Network.new }

    let(:value) { '10.16.122.163' }

    before do
      allow(Facter::Resolvers::Linux::Networking).to receive(:resolve).with(:network).and_return(value)
    end

    it 'calls Facter::Resolvers::NetworkingLinux with network' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Networking).to have_received(:resolve).with(:network)
    end

    it 'returns network fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array)
        .and contain_exactly(an_object_having_attributes(name: 'networking.network', value: value),
                             an_object_having_attributes(name: 'network', value: value, type: :legacy))
    end

    context 'when network can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.network', value: value),
                          an_object_having_attributes(name: 'network', value: value, type: :legacy))
      end
    end
  end
end
