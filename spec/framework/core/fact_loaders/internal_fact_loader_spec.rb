# frozen_string_literal: true

describe 'InternalFactLoader' do
  before do
    allow_any_instance_of(OsDetector).to receive(:hierarchy).and_return([:Debian])
  end

  describe '#initialize' do
    context 'load facts' do
      it 'loads one legacy fact and sees it as core' do
        allow_any_instance_of(OsDetector).to receive(:hierarchy).and_return([:Windows])
        allow_any_instance_of(Facter::ClassDiscoverer)
          .to receive(:discover_classes)
          .with(:Windows)
          .and_return([:NetworkInterfaces])

        stub_const('Facter::Windows::NetworkInterfaces::FACT_NAME', 'network_.*')

        internal_fact_loader = Facter::InternalFactLoader.new
        legacy_facts = internal_fact_loader.legacy_facts
        core_facts = internal_fact_loader.core_facts

        expect(legacy_facts.size).to eq(0)
        expect(core_facts.size).to eq(1)
        expect(core_facts.first.type).to eq(:core)
      end

      it 'loads one core fact' do
        allow_any_instance_of(Facter::ClassDiscoverer)
          .to receive(:discover_classes)
          .with(:Debian)
          .and_return([:OsName])

        stub_const('Facter::Ubuntu::OsName::FACT_NAME', 'os.name')

        internal_fact_loader = Facter::InternalFactLoader.new
        core_facts = internal_fact_loader.core_facts

        expect(core_facts.size).to eq(2)
        expect(core_facts.first.type).to eq(:core)
      end

      it 'loads one legacy fact and one core fact' do
        allow_any_instance_of(OsDetector).to receive(:hierarchy).and_return([:Windows])

        allow_any_instance_of(Facter::ClassDiscoverer)
          .to receive(:discover_classes)
          .with(:Windows)
          .and_return(%i[NetworkInterfaces OsName])

        stub_const('Facter::Windows::NetworkInterface::FACT_NAME', 'network_.*')
        stub_const('Facter::Windows::OsName::FACT_NAME', 'os.name')

        internal_fact_loader = Facter::InternalFactLoader.new
        all_facts = internal_fact_loader.facts

        expect(all_facts.size).to eq(3)
        all_facts.each do |fact|
          expect(fact.type).to eq(:core)
        end
      end

      it 'loads no facts' do
        allow_any_instance_of(Facter::ClassDiscoverer)
          .to receive(:discover_classes)
          .with(:Debian)
          .and_return([])
        internal_fact_loader = Facter::InternalFactLoader.new
        all_facts_hash = internal_fact_loader.facts

        expect(all_facts_hash.size).to eq(0)
      end
    end
  end
end
