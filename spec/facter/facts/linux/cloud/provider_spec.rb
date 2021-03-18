# frozen_string_literal: true

describe Facts::Linux::Cloud::Provider do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Cloud::Provider.new }

    let(:virtual_detector) { instance_spy(Facter::Util::Facts::VirtualDetector) }

    before do
      allow(Facter::Util::Facts::VirtualDetector).to receive(:new).and_return(virtual_detector)
    end

    context 'when on hyperv' do
      before do
        allow(Facter::Resolvers::Az).to receive(:resolve).with(:metadata).and_return(value)
        allow(virtual_detector).to receive(:platform).and_return('hyperv')
      end

      context 'when az_metadata exists' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns azure as cloud.provider' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'azure')
        end
      end

      context 'when az_metadata does not exist' do
        let(:value) { {} }

        it 'returns nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: nil)
        end
      end
    end

    context 'when on a physical machine' do
      before do
        allow(virtual_detector).to receive(:platform).and_return(nil)
      end

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'cloud.provider', value: nil)
      end
    end
  end
end
