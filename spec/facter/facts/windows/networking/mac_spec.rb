# frozen_string_literal: true

describe 'Windows NetworkingMac' do
  context '#call_the_resolver' do
    let(:value) { '00:50:56:9A:7E:98' }
    subject(:fact) { Facter::Windows::NetworkingMac.new }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:mac).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Networking).to receive(:resolve).with(:mac)
      fact.call_the_resolver
    end

    it 'returns mac address fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.mac', value: value),
                        an_object_having_attributes(name: 'macaddress', value: value, type: :legacy))
    end
  end
end
