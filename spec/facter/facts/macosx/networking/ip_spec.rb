# frozen_string_literal: true

describe Facts::Macosx::Networking::Ip do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Networking::Ip.new }

    let(:value) { '10.0.0.1' }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:ip).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking with :ip' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Networking).to have_received(:resolve).with(:ip)
    end

    it 'returns the ip6 fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.ip', value: value),
                        an_object_having_attributes(name: 'ipaddress', value: value, type: :legacy))
    end

    context 'when ip can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.ip', value: value),
                          an_object_having_attributes(name: 'ipaddress', value: value, type: :legacy))
      end
    end
  end
end
