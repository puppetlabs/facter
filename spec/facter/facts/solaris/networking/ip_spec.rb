# frozen_string_literal: true

describe Facts::Solaris::Networking::Ip do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Networking::Ip.new }

    let(:value) { '10.0.0.1' }

    before do
      allow(Facter::Resolvers::Solaris::Ipaddress).to receive(:resolve).with(:ip).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::Ipaddress' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Ipaddress).to have_received(:resolve).with(:ip)
    end

    it 'return ip fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.ip', value: value),
                        an_object_having_attributes(name: 'ipaddress', value: value, type: :legacy))
    end
  end
end
