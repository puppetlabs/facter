# frozen_string_literal: true

describe Facts::Windows::Networking::Ip do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Networking::Ip.new }

    let(:value) { '0.16.121.255' }

    before do
      allow(Facter::Resolvers::Windows::Networking).to receive(:resolve).with(:ip).and_return(value)
    end

    it 'returns ipv4 address fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.ip', value: value),
                        an_object_having_attributes(name: 'ipaddress', value: value, type: :legacy))
    end
  end
end
