# frozen_string_literal: true

describe Facts::Linux::Networking::Network6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Networking::Network6.new }

    let(:value) { 'fe80::5989:97ff:75ae:dae7' }

    before do
      allow(Facter::Resolvers::Linux::Networking).to receive(:resolve).with(:network6).and_return(value)
    end

    it 'calls Facter::Resolvers::NetworkingLinux with network6' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Networking).to have_received(:resolve).with(:network6)
    end

    it 'returns network6 fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.network6', value: value),
                        an_object_having_attributes(name: 'network6', value: value, type: :legacy))
    end

    context 'when network6 can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.network6', value: value),
                          an_object_having_attributes(name: 'network6', value: value, type: :legacy))
      end
    end
  end
end
