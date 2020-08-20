# frozen_string_literal: true

describe Facts::Solaris::Virtual do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Virtual.new }

    let(:processor) { 'i386' }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:processor).and_return(processor)
    end

    context 'when no hypervisor is found' do
      let(:vm) { 'physical' }
      let(:current_zone_name) { 'global' }
      let(:role_control) { 'false' }

      before do
        allow(Facter::Resolvers::Solaris::ZoneName)
          .to receive(:resolve)
          .with(:current_zone_name)
          .and_return(current_zone_name)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_impl).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_control).and_return(nil)
        allow(Facter::Resolvers::Solaris::Dmi).to receive(:resolve).with(:product_name).and_return('unkown')
        allow(Facter::Resolvers::Solaris::Dmi).to receive(:resolve).with(:bios_vendor).and_return('unkown')
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
      end

      it 'returns virtual fact as physical' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: vm)
      end
    end

    context 'when ldom hypervisor is found' do
      let(:vm) { 'LDoms' }
      let(:current_zone_name) { 'global' }

      before do
        allow(Facter::Resolvers::Solaris::ZoneName)
          .to receive(:resolve)
          .with(:current_zone_name)
          .and_return(current_zone_name)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_impl).and_return(vm)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_control).and_return(role_control)
      end

      context 'when role_control is false' do
        let(:role_control) { 'false' }

        it 'returns virtual fact as physical' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'virtual', value: vm)
        end
      end

      context 'when role_control is true' do
        let(:role_control) { 'true' }
        let(:vm) { 'physical' }

        it 'returns virtual fact as physical' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'virtual', value: vm)
        end
      end
    end

    context 'when zone hypervisor is found' do
      let(:vm) { 'zone' }

      before do
        allow(Facter::Resolvers::Solaris::ZoneName).to receive(:resolve).with(:current_zone_name).and_return(vm)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_impl).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_control).and_return(nil)
      end

      it 'returns virtual fact as physical' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: vm)
      end
    end

    context 'when xen hypervisor is found' do
      let(:current_zone_name) { 'global' }
      let(:role_control) { 'false' }
      let(:xen_vm) { 'xenhvm' }

      before do
        allow(Facter::Resolvers::Solaris::ZoneName)
          .to receive(:resolve)
          .with(:current_zone_name)
          .and_return(current_zone_name)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_impl).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_control).and_return(nil)
        allow(Facter::Resolvers::Solaris::Dmi).to receive(:resolve).with(:product_name).and_return('unkown')
        allow(Facter::Resolvers::Solaris::Dmi).to receive(:resolve).with(:bios_vendor).and_return('unkown')
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(xen_vm)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: xen_vm)
      end
    end

    context 'when other hypervisors' do
      let(:vm) { 'global' }

      before do
        allow(Facter::Resolvers::Solaris::ZoneName).to receive(:resolve).with(:current_zone_name).and_return(vm)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_impl).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_control).and_return(nil)
      end

      context 'when processor is i386' do
        let(:processor) { 'i386' }
        let(:dmi) { class_double(Facter::Resolvers::Solaris::Dmi).as_stubbed_const }

        before do
          allow(dmi).to receive(:resolve)
        end

        it 'calls Dmi resolver for product_name' do
          fact.call_the_resolver
          expect(dmi).to have_received(:resolve).with(:product_name)
        end

        it 'calls Dmi resolver for bios_vendor' do
          fact.call_the_resolver
          expect(dmi).to have_received(:resolve).with(:bios_vendor)
        end
      end

      context 'when processor is sparc' do
        let(:processor) { 'sparc' }
        let(:dmi) { class_double(Facter::Resolvers::Solaris::DmiSparc).as_stubbed_const }

        before do
          allow(dmi).to receive(:resolve)
        end

        it 'calls DmiSparc resolver for product_name' do
          fact.call_the_resolver
          expect(dmi).to have_received(:resolve).with(:product_name)
        end

        it 'calls DmiSparc resolver for bios_vendor' do
          fact.call_the_resolver
          expect(dmi).to have_received(:resolve).with(:bios_vendor)
        end
      end
    end
  end
end
