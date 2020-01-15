# frozen_string_literal: true

describe 'Windows NetworkInterfaces' do
  context '#call_the_resolver' do
    let(:interfaces) { { 'eth0' => { network: '10.255.255.255' }, 'en1' => { network: '10.17.255.255' } } }
    subject(:fact) { Facter::Windows::NetworkInterfaces.new }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces)
      fact.call_the_resolver
    end

    it 'returns legacy facts with names network_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'network_eth0',
                                                    value: interfaces['eth0'][:network], type: :legacy),
                        an_object_having_attributes(name: 'network_en1',
                                                    value: interfaces['en1'][:network], type: :legacy))
    end
  end
end
