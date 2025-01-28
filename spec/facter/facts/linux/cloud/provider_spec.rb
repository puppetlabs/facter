# frozen_string_literal: true

describe Facts::Linux::Cloud::Provider do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Cloud::Provider.new }

    context 'when on hyperv' do
      before do
        allow(Facter::Resolvers::Az).to receive(:resolve).with(:metadata).and_return(value)
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return('hyperv')
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
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return(nil)
      end

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'cloud.provider', value: nil)
      end
    end

    describe 'when on kvm' do
      before do
        allow(Facter::Resolvers::Ec2).to receive(:resolve).with(:metadata).and_return(value)
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return('kvm')
      end

      describe 'Ec2 data exists and not running as root' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns aws' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(true)
          allow(Process).to receive(:uid).and_return(512)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('kvm')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'aws')
        end
      end

      describe 'Ec2 data exists and virt-what is not executable' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns aws' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(false)
          allow(Process).to receive(:uid).and_return(0)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('kvm')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'aws')
        end
      end

      describe 'Ec2 data exists and virt-what returns aws' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns aws' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(true)
          allow(Process).to receive(:uid).and_return(0)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('aws')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'aws')
        end
      end

      describe 'Ec2 data exists and virt-what returns not aws' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns nil' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(true)
          allow(Process).to receive(:uid).and_return(0)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('kvm')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: nil)
        end
      end

      context 'when Ec2 data does not exist nil is returned' do
        let(:value) { {} }

        it 'returns nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: nil)
        end
      end
    end

    describe 'when on xen' do
      before do
        allow(Facter::Resolvers::Ec2).to receive(:resolve).with(:metadata).and_return(value)
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return('xen')
      end

      describe 'Ec2 data exists and not running as root' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns aws' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(true)
          allow(Process).to receive(:uid).and_return(512)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('kvm')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'aws')
        end
      end

      describe 'Ec2 data exists and virt-what is not executable' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns aws' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(false)
          allow(Process).to receive(:uid).and_return(0)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('kvm')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'aws')
        end
      end

      describe 'Ec2 data exists and virt-what returns aws' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns aws' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(true)
          allow(Process).to receive(:uid).and_return(0)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('aws')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'aws')
        end
      end

      describe 'Ec2 data exists and virt-what returns not aws' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns nil' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(true)
          allow(Process).to receive(:uid).and_return(0)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('kvm')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: nil)
        end
      end

      context 'when Ec2 data does not exist nil is returned' do
        let(:value) { {} }

        it 'returns nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: nil)
        end
      end
    end

    describe 'when on xenhvm' do
      before do
        allow(Facter::Resolvers::Ec2).to receive(:resolve).with(:metadata).and_return(value)
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return('xenhvm')
      end

      describe 'Ec2 data exists and not running as root' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns aws' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(true)
          allow(Process).to receive(:uid).and_return(512)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('kvm')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'aws')
        end
      end

      describe 'Ec2 data exists and virt-what is not executable' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns aws' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(false)
          allow(Process).to receive(:uid).and_return(0)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('kvm')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'aws')
        end
      end

      describe 'Ec2 data exists and virt-what returns aws' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns aws' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(true)
          allow(Process).to receive(:uid).and_return(0)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('aws')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'aws')
        end
      end

      describe 'Ec2 data exists and virt-what returns not aws' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns nil' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(true)
          allow(Process).to receive(:uid).and_return(0)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('kvm')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: nil)
        end
      end

      context 'when Ec2 data does not exist nil is returned' do
        let(:value) { {} }

        it 'returns nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: nil)
        end
      end
    end

    describe 'when on xenu' do
      before do
        allow(Facter::Resolvers::Ec2).to receive(:resolve).with(:metadata).and_return(value)
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return('xenu')
      end

      describe 'Ec2 data exists and not running as root' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns aws' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(true)
          allow(Process).to receive(:uid).and_return(512)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('kvm')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'aws')
        end
      end

      describe 'Ec2 data exists and virt-what is not executable' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns aws' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(false)
          allow(Process).to receive(:uid).and_return(0)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('kvm')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'aws')
        end
      end

      describe 'Ec2 data exists and virt-what returns aws' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns aws' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(true)
          allow(Process).to receive(:uid).and_return(0)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('aws')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'aws')
        end
      end

      describe 'Ec2 data exists and virt-what returns not aws' do
        let(:value) { { 'some' => 'fact' } }

        it 'returns nil' do
          allow(File).to receive(:executable?).with('/opt/puppetlabs/puppet/bin/virt-what').and_return(true)
          allow(Process).to receive(:uid).and_return(0)
          allow(Facter::Core::Execution).to receive(:execute).with('/opt/puppetlabs/puppet/bin/virt-what').and_return('kvm')
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: nil)
        end
      end

      context 'when Ec2 data does not exist, nil is returned' do
        let(:value) { {} }

        it 'returns nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: nil)
        end
      end
    end

    describe 'when on gce' do
      before do
        allow(Facter::Resolvers::Gce).to receive(:resolve).with(:metadata).and_return(value)
        allow(Facter::Util::Facts::Posix::VirtualDetector).to receive(:platform).and_return('gce')
      end

      describe 'and the "gce" fact has content' do
        let(:value) { { 'some' => 'metadata' } }

        it 'resolves a provider of "gce"' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: 'gce')
        end
      end

      context 'when the "gce" fact has no content' do
        let(:value) { {} }

        it 'resolves to nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'cloud.provider', value: nil)
        end
      end
    end
  end
end
