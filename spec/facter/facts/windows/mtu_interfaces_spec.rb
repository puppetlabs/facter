# frozen_string_literal: true

describe 'Windows MtuInterfaces' do
  context '#call_the_resolver' do
    let(:interfaces) { { 'eth0' => { mtu: 1500 }, 'en1' => { mtu: 1500 } } }
    subject(:fact) { Facter::Windows::MtuInterfaces.new }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces)
      fact.call_the_resolver
    end

    it 'returns legacy facts with names mtu_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'mtu_eth0', value: interfaces['eth0'][:mtu], type: :legacy),
                        an_object_having_attributes(name: 'mtu_en1', value: interfaces['en1'][:mtu], type: :legacy))
    end
  end
end
