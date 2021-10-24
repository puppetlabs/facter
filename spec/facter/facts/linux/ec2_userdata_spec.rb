# frozen_string_literal: true

describe Facts::Linux::Ec2Userdata do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Ec2Userdata.new }

    let(:virtual_detector_double) { class_spy(Facter::Util::Facts::Posix::VirtualDetector) }

    before do
      allow(Facter::Resolvers::Ec2).to receive(:resolve).with(:userdata).and_return(value)
    end

    context 'when physical machine with no hypervisor' do
      let(:value) { nil }

      before do
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return('nil')
      end

      it 'returns ec2 userdata fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'ec2_userdata', value: value)
      end

      it "doesn't call Ec2 resolver" do
        fact.call_the_resolver
        expect(Facter::Resolvers::Ec2).not_to have_received(:resolve).with(:userdata)
      end
    end

    shared_examples 'check ec2 resolver called with userdata' do
      it 'calls ec2 resolver' do
        fact.call_the_resolver

        expect(Facter::Resolvers::Ec2).to have_received(:resolve).with(:userdata)
      end
    end

    shared_examples 'check resolved fact value' do
      it 'returns ec2 userdata fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'ec2_userdata', value: value)
      end
    end

    context 'when platform is kvm' do
      let(:value) { { 'info' => 'value' } }

      before do
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return('kvm')
      end

      it_behaves_like 'check ec2 resolver called with userdata'
      it_behaves_like 'check resolved fact value'
    end

    context 'when platform is xen' do
      let(:value) { { 'info' => 'value' } }

      before do
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return('xen')
      end

      it_behaves_like 'check ec2 resolver called with userdata'
      it_behaves_like 'check resolved fact value'
    end

    context 'when platform is aws' do
      let(:value) { { 'info' => 'value' } }

      before do
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return('aws')
      end

      it_behaves_like 'check ec2 resolver called with userdata'
      it_behaves_like 'check resolved fact value'
    end
  end
end
