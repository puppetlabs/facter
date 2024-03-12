# frozen_string_literal: true

describe Facts::Openbsd::IsVirtual do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Openbsd::IsVirtual.new }

    let(:virtual_detector_double) { class_spy(Facter::Util::Facts::Posix::VirtualDetector) }

    before do
      allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return(virtual_value)
    end

    context 'when not in a virtual environment' do
      let(:virtual_value) { 'physical' }

      it 'return resolved fact with nil value' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'is_virtual', value: false)
      end
    end

    context 'when in a virtual environment' do
      let(:virtual_value) { 'vmm' }

      it 'return resolved fact with nil value' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'is_virtual', value: true)
      end
    end
  end
end
