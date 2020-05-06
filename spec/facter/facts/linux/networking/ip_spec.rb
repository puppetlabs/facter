# frozen_string_literal: true

describe Facts::Linux::Networking::Ip do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Networking::Ip.new }

    let(:value) { '10.16.122.163' }

    before do
      allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:ip).and_return(value)
    end

    it 'calls Facter::Resolvers::NetworkingLinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:ip)
    end

    it 'returns ipaddress fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array)
        .and contain_exactly(an_object_having_attributes(name: 'networking.ip', value: value),
                             an_object_having_attributes(name: 'ipaddress', value: value, type: :legacy))
    end
  end
end
