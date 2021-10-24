# frozen_string_literal: true

describe Facts::Linux::Networking::Hostname do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Networking::Hostname.new }

    let(:value) { 'host' }

    before do
      allow(Facter::Resolvers::Linux::Hostname).to receive(:resolve).with(:hostname).and_return(value)
    end

    it 'calls Facter::Resolvers::Hostname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Hostname).to have_received(:resolve).with(:hostname)
    end

    it 'returns hostname fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.hostname', value: value),
                        an_object_having_attributes(name: 'hostname', value: value, type: :legacy))
    end

    context 'when hostname can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.hostname', value: value),
                          an_object_having_attributes(name: 'hostname', value: value, type: :legacy))
      end
    end
  end
end
