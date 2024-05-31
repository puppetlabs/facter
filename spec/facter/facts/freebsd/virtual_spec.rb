# frozen_string_literal: true

describe Facts::Freebsd::Virtual do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Virtual.new }

    let(:virtual_detector_double) { class_spy(Facter::Util::Facts::Posix::VirtualDetector) }

    before do
      allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return(value)
    end

    shared_examples 'check resolved fact value' do
      it 'return resolved fact with nil value' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'virtual', value: value)
      end
    end

    context 'when not in a virtual environment' do
      let(:value) { 'physical' }

      it_behaves_like 'check resolved fact value'
    end

    context 'when in a virtual environment' do
      let(:value) { 'jail' }

      it_behaves_like 'check resolved fact value'
    end
  end
end
