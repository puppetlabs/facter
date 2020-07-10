# frozen_string_literal: true

describe Facts::Windows::Ec2Userdata do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Ec2Userdata.new }

    before do
      allow(Facter::Resolvers::Ec2).to receive(:resolve).with(:userdata).and_return(value)
      allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return(hypervisor)
    end

    context 'when hypervisor is not kvm or xen' do
      let(:hypervisor) { nil }
      let(:value) { nil }

      it 'returns ec2 userdata fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'ec2_userdata', value: nil)
      end

      it "doesn't call Ec2 resolver" do
        fact.call_the_resolver
        expect(Facter::Resolvers::Ec2).not_to have_received(:resolve).with(:userdata)
      end
    end

    context 'when hypervisor is xen' do
      let(:hypervisor) { 'xen' }

      context 'when resolver returns a value' do
        let(:value) { 'some custom value' }

        it 'calls Facter::Resolvers::Ec2' do
          fact.call_the_resolver
          expect(Facter::Resolvers::Ec2).to have_received(:resolve).with(:userdata)
        end

        it 'returns ec2 userdata fact' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'ec2_userdata', value: value)
        end
      end

      context 'when resolver returns empty string' do
        let(:value) { '' }

        it 'returns ec2 userdata fact as nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'ec2_userdata', value: nil)
        end
      end
    end
  end
end
