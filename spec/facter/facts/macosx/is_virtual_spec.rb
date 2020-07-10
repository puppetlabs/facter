# frozen_string_literal: true

describe Facts::Macosx::IsVirtual do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::IsVirtual.new }

    before do
      allow(Facter::Resolvers::Macosx::SystemProfiler).to receive(:resolve)
        .with(:model_identifier)
        .and_return('MacBookPro11,4')

      allow(Facter::Resolvers::Macosx::SystemProfiler).to receive(:resolve)
        .with(:boot_rom_version)
        .and_return('1037.60.58.0.0 (iBridge: 17.16.12551.0.0,0)')

      allow(Facter::Resolvers::Macosx::SystemProfiler).to receive(:resolve)
        .with(:subsystem_vendor_id)
        .and_return('0x123')
    end

    context 'when on physical machine' do
      it 'calls Facter::Resolvers::Macosx::SystemProfile with model_identifier' do
        fact.call_the_resolver

        expect(Facter::Resolvers::Macosx::SystemProfiler).to have_received(:resolve).with(:model_identifier)
      end

      it 'calls Facter::Resolvers::Macosx::SystemProfile with boot_rom_version' do
        fact.call_the_resolver

        expect(Facter::Resolvers::Macosx::SystemProfiler).to have_received(:resolve).with(:boot_rom_version)
      end

      it 'calls Facter::Resolvers::Macosx::SystemProfile with subsystem_vendor_id' do
        fact.call_the_resolver

        expect(Facter::Resolvers::Macosx::SystemProfiler).to have_received(:resolve).with(:subsystem_vendor_id)
      end

      it 'returns resolved fact with false value' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'is_virtual', value: false)
      end
    end

    context 'when on virtual machine' do
      context 'with hypervisor vmware' do
        before do
          allow(Facter::Resolvers::Macosx::SystemProfiler)
            .to receive(:resolve)
            .with(:model_identifier)
            .and_return('VMware')
        end

        it 'returns resolved fact with true value' do
          expect(fact.call_the_resolver)
            .to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'is_virtual', value: true)
        end
      end

      context 'when hypervisor VirtualBox' do
        before do
          allow(Facter::Resolvers::Macosx::SystemProfiler)
            .to receive(:resolve)
            .with(:boot_rom_version)
            .and_return('VirtualBox')
        end

        it 'returns resolved fact with true value' do
          expect(fact.call_the_resolver)
            .to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'is_virtual', value: true)
        end
      end

      context 'when hypervisor Parallels' do
        before do
          allow(Facter::Resolvers::Macosx::SystemProfiler)
            .to receive(:resolve)
            .with(:subsystem_vendor_id)
            .and_return('0x1ab8')
        end

        it 'returns resolved fact with true value' do
          expect(fact.call_the_resolver)
            .to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'is_virtual', value: true)
        end
      end
    end
  end
end
