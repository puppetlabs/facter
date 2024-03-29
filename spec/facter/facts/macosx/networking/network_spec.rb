# frozen_string_literal: true

describe Facts::Macosx::Networking::Network do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Networking::Network.new }

    let(:value) { '192.168.143.0' }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:network).and_return(value)
    end

    it 'returns the network fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.network', value: value),
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
