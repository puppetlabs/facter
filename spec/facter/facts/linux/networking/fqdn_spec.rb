# frozen_string_literal: true

describe Facts::Linux::Networking::Fqdn do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Networking::Fqdn.new }

    let(:value) { 'host.domain' }

    before do
      allow(Facter::Resolvers::Linux::Hostname).to receive(:resolve).with(:fqdn).and_return(value)
    end

    it 'calls Facter::Resolvers::Hostname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Hostname).to have_received(:resolve).with(:fqdn)
    end

    it 'returns fqdn fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.fqdn', value: value),
                        an_object_having_attributes(name: 'fqdn', value: value, type: :legacy))
    end

    context 'when fqdn can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.fqdn', value: value),
                          an_object_having_attributes(name: 'fqdn', value: value, type: :legacy))
      end
    end
  end
end
