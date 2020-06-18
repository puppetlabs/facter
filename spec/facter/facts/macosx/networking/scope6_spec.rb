# frozen_string_literal: true

describe Facts::Macosx::Networking::Scope6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Networking::Scope6.new }

    let(:value) { 'link' }
    let(:interfaces) { { 'eth0' => { ip: 'ff80:158::', scope6: value } } }
    let(:primary) { 'eth0' }

    before do
      allow(Facter::Resolvers::Macosx::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
      allow(Facter::Resolvers::Macosx::Networking).to receive(:resolve).with(:primary_interface).and_return(primary)
    end

    it 'calls Facts::Macosx::Networking::Scope6 with interfaces' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'calls Facts::Macosx::Networking::Scope6 with primary_interface' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Networking).to have_received(:resolve).with(:primary_interface)
    end

    it 'returns scope6 fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.scope6', value: value)
    end

    context 'when primary interface does not have an ipv6 address' do
      let(:value) { nil }
      let(:interfaces) { { 'eth0' => { ip: '10.16.122.163' } } }

      it 'returns nil' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'networking.scope6', value: value)
      end
    end
  end
end
