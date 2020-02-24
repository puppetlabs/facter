# frozen_string_literal: true

describe Facter::Macosx::IsVirtual do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Macosx::IsVirtual.new }

    before do
      allow(Facter::Resolvers::SystemProfiler).to receive(:resolve)
        .with(:model_identifier)
        .and_return('MacBookPro11,4')

      allow(Facter::Resolvers::SystemProfiler).to receive(:resolve)
        .with(:boot_rom_version)
        .and_return('1037.60.58.0.0 (iBridge: 17.16.12551.0.0,0)')

      allow(Facter::Resolvers::SystemProfiler).to receive(:resolve)
        .with(:subsystem_vendor_id)
        .and_return('0x123')
    end

    it 'calls Facter::Resolvers::SystemProfile with model_identifier' do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve)
        .with(:model_identifier)
      fact.call_the_resolver
    end

    it 'calls Facter::Resolvers::SystemProfile with boot_rom_version' do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve)
        .with(:boot_rom_version)
      fact.call_the_resolver
    end

    it 'calls Facter::Resolvers::SystemProfile with subsystem_vendor_id' do
      allow(Facter::Resolvers::SystemProfiler).to receive(:resolve)
        .with(:subsystem_vendor_id)
      fact.call_the_resolver
    end

    context 'on virtual machine' do
      context 'on vmware' do
        before do
          allow(Facter::Resolvers::SystemProfiler)
            .to receive(:resolve)
            .with(:model_identifier)
            .and_return('VMware')
        end

        it 'returns resolved fact with true value' do
          expect(fact.call_the_resolver)
            .to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'is_virtual', value: true)

          fact.call_the_resolver
        end
      end

      context 'on VirtualBox' do
        before do
          allow(Facter::Resolvers::SystemProfiler)
            .to receive(:resolve)
            .with(:boot_rom_version)
            .and_return('VirtualBox')
        end

        it 'returns resolved fact with true value' do
          expect(fact.call_the_resolver)
            .to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'is_virtual', value: true)

          fact.call_the_resolver
        end
      end

      context 'on Parallels' do
        before do
          allow(Facter::Resolvers::SystemProfiler)
            .to receive(:resolve)
            .with(:subsystem_vendor_id)
            .and_return('0x1ab8')
        end

        it 'returns resolved fact with true value' do
          expect(fact.call_the_resolver)
            .to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'is_virtual', value: true)

          fact.call_the_resolver
        end
      end
    end

    context 'on physical machine' do
      it 'returns resolved fact with false value' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'is_virtual', value: false)
      end
    end
  end
end
