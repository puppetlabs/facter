# frozen_string_literal: true

describe 'Windows NetmaskInterfaces' do
  context '#call_the_resolver' do
    let(:interfaces) { { 'eth0' => { netmask: '10.255.255.255' }, 'en1' => { netmask: '10.17.255.255' } } }
    subject(:fact) { Facter::Windows::NetmaskInterfaces.new }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces)
      fact.call_the_resolver
    end

    it 'returns legacy facts with names netmask_<interface_name>' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'netmask_eth0',
                                                    value: interfaces['eth0'][:netmask], type: :legacy),
                        an_object_having_attributes(name: 'netmask_en1',
                                                    value: interfaces['en1'][:netmask], type: :legacy))
    end
  end
end
