# frozen_string_literal: true

describe Facts::Linux::Hypervisors::Openvz do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Hypervisors::Openvz.new }

    before do
      allow(Facter::Resolvers::OpenVz).to \
        receive(:resolve).with(:vm).and_return(ovz)
    end

    context 'when resolver returns nil' do
      let(:ovz) { nil }

      it 'calls Facter::Resolvers::OpenVz' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OpenVz).to have_received(:resolve).with(:vm)
      end

      it 'returns virtual fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.openvz', value: nil)
      end
    end

    context 'when resolver returns openvz host' do
      before { allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:id).and_return('0') }

      let(:ovz) { 'openvzhn' }
      let(:value) { { 'id' => 0, 'host' => true } }

      it 'returns openvz info' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.openvz', value: value)
      end
    end

    context 'when resolver returns openvz' do
      before { allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:id).and_return('101') }

      let(:ovz) { 'openvze' }
      let(:value) { { 'id' => 101, 'host' => false } }

      it 'returns openvz info' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.openvz', value: value)
      end
    end
  end
end
