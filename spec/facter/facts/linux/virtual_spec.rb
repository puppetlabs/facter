# frozen_string_literal: true

describe Facts::Linux::Virtual do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Virtual.new }

    let(:virtual_detector_double) { instance_spy(Facter::Util::Facts::VirtualDetector) }
    let(:log_spy) { instance_spy(Facter::Log) }

    before do
      allow(Facter::Log).to receive(:new).and_return(log_spy)
      allow(Facter::Util::Facts::VirtualDetector).to receive(:new).and_return(virtual_detector_double)
      allow(virtual_detector_double).to receive(:platform).and_return(value)
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
      let(:value) { 'aws' }

      it_behaves_like 'check resolved fact value'
    end
  end
end
