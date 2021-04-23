# frozen_string_literal: true

describe Facts::Linux::AzMetadata do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::AzMetadata.new }

    let(:virtual_detector_double) { class_spy(Facter::Util::Facts::Posix::VirtualDetector) }

    before do
      allow(Facter::Resolvers::Az).to receive(:resolve).with(:metadata).and_return(value)
    end

    context 'when physical machine with no hypervisor' do
      let(:value) { nil }

      before do
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return(nil)
      end

      it 'returns az metadata fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'az_metadata', value: value)
      end

      it "doesn't call az resolver" do
        fact.call_the_resolver
        expect(Facter::Resolvers::Az).not_to have_received(:resolve).with(:metadata)
      end
    end

    context 'when platform is hyperv' do
      let(:value) { { 'info' => 'value' } }

      before do
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return('hyperv')
      end

      context 'when on Azure' do
        it 'calls the az resolver' do
          fact.call_the_resolver

          expect(Facter::Resolvers::Az).to have_received(:resolve).with(:metadata)
        end

        it 'returns az_metadata fact' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'az_metadata', value: value)
        end
      end

      context 'when not on Azure' do
        let(:value) { nil }

        it 'returns az_metadata fact as nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'az_metadata', value: value)
        end
      end
    end
  end
end
