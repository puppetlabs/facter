# frozen_string_literal: true

describe Facts::Macosx::Networking::Mtu do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Networking::Mtu.new }

    let(:value) { 1500 }
    let(:primary) { 'en0' }
    let(:interfaces) { { 'en0' => { mtu: 1500 } } }

    before do
      allow(Facter::Resolvers::Macosx::Networking).to receive(:resolve).with(:primary_interface).and_return(primary)
      allow(Facter::Resolvers::Macosx::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
    end

    it 'calls Facter::Resolvers::Macosx::Networking with :primary_interface' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Networking).to have_received(:resolve).with(:primary_interface)
    end

    it 'calls Facter::Resolvers::Macosx::Networking with :interfaces' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'returns mtu fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact).and have_attributes(name: 'networking.mtu', value: value)
    end

    context 'when primary interface can not be retrieved' do
      let(:primary) { nil }
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact).and have_attributes(name: 'networking.mtu', value: value)
      end
    end

    context 'when interfaces can not be retrieved' do
      let(:interfaces) { nil }
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact).and have_attributes(name: 'networking.mtu', value: value)
      end
    end
  end
end
