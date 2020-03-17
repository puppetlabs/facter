# frozen_string_literal: true

describe Facts::Debian::Networking::Mac do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Networking::Mac.new }

    let(:value) { '64:5a:ed:ea:c3:25' }

    before do
      allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:macaddress).and_return(value)
    end

    it 'calls Facter::Resolvers::NetworkingLinux' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:macaddress)
    end

    it 'return macaddress fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.mac', value: value),
                        an_object_having_attributes(name: 'macaddress', value: value, type: :legacy))
    end
  end
end
