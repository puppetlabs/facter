# frozen_string_literal: true

describe Facts::Solaris::IsVirtual do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::IsVirtual.new }

    let(:processor) { 'i386' }
    let(:logger_double) { instance_spy(Facter::Log) }

    before do
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:processor).and_return(processor)
    end

    context 'when no hypervisor is found' do
      let(:vm) { false }
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
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(nil)
      end

      it 'returns is_virtual fact as false' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: vm)
      end
    end

    context 'when Ldom role_control is false, ldom hypervisor is found' do
      let(:vm) { true }
      let(:role_control) { 'false' }

      before do
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_impl).and_return(vm)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_control).and_return(role_control)
      end

      it 'returns is_virtual fact as true' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: vm)
      end
    end

    context 'when Ldom role_control is true' do
      let(:role_control) { 'true' }
      let(:vm) { false }
      let(:current_zone_name) { 'global' }

      before do
        allow(Facter::Resolvers::Solaris::ZoneName)
          .to receive(:resolve)
          .with(:current_zone_name)
          .and_return(current_zone_name)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_impl).and_return(vm)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_control).and_return(role_control)
        allow(Facter::Resolvers::Solaris::Dmi).to receive(:resolve).with(:product_name).and_return(nil)
        allow(Facter::Resolvers::Solaris::Dmi).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(nil)
      end

      it 'returns is_virtual fact as false' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: vm)
      end
    end

    context 'when zone hypervisor is found' do
      let(:vm) { true }

      before do
        allow(Facter::Resolvers::Solaris::ZoneName).to receive(:resolve).with(:current_zone_name).and_return(vm)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_impl).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_control).and_return(nil)
      end

      it 'returns is_virtual fact as physical' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: vm)
      end
    end

    context 'when xen hypervisor is found' do
      let(:current_zone_name) { 'global' }
      let(:role_control) { 'false' }
      let(:xen_vm) { true }

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

      it 'returns is_virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: xen_vm)
      end
    end

    context 'when other hypervisors' do
      let(:vm) { 'global' }

      before do
        allow(Facter::Resolvers::Solaris::ZoneName).to receive(:resolve).with(:current_zone_name).and_return(vm)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_impl).and_return(nil)
        allow(Facter::Resolvers::Solaris::Ldom).to receive(:resolve).with(:role_control).and_return(nil)
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(nil)
      end

      context 'when processor is i386' do
        let(:processor) { 'i386' }
        let(:dmi) { class_double(Facter::Resolvers::Solaris::Dmi).as_stubbed_const }

        before do
          allow(dmi).to receive(:resolve)
        end

        it 'returns is_virtual fact' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'is_virtual', value: false)
        end
      end

      context 'when processor is sparc' do
        let(:processor) { 'sparc' }
        let(:dmi) { class_spy(Facter::Resolvers::Solaris::DmiSparc).as_stubbed_const }

        before do
          allow(dmi).to receive(:resolve)
        end

        it 'returns is_virtual fact' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'is_virtual', value: false)
        end
      end
    end
  end
end
