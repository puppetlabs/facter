# frozen_string_literal: true

describe Facter::InternalFactLoader do
  describe '#initialize' do
    subject(:internal_fact_loader) { Facter::InternalFactLoader.new }

    let(:os_detector_mock) { instance_spy(OsDetector) }
    let(:class_discoverer_mock) { instance_spy(Facter::ClassDiscoverer) }

    before do
      allow(os_detector_mock).to receive(:hierarchy).and_return([:Linux])
      allow(OsDetector).to receive(:instance).and_return(os_detector_mock)
    end

    context 'when loading one legacy fact' do
      before do
        allow(os_detector_mock).to receive(:hierarchy).and_return([:Windows])
        allow(OsDetector).to receive(:instance).and_return(os_detector_mock)

        allow(class_discoverer_mock)
          .to receive(:discover_classes)
          .with(:Windows)
          .and_return([Facts::Windows::NetworkInterfaces])
        allow(Facter::ClassDiscoverer).to receive(:instance).and_return(class_discoverer_mock)

        stub_const('Facts::Windows::NetworkInterfaces::FACT_NAME', 'network_.*')
      end

      it 'loads no core facts' do
        expect(internal_fact_loader.core_facts).to be_empty
      end

      it 'loads one legacy fact' do
        expect(internal_fact_loader.legacy_facts.size).to eq(1)
      end

      it 'loads one fact with :legacy type' do
        expect(internal_fact_loader.legacy_facts.first.type).to eq(:legacy)
      end
    end

    context 'when loading one core fact' do
      before do
        allow(class_discoverer_mock)
          .to receive(:discover_classes)
          .with(:Linux)
          .and_return([Facts::Linux::Path])
        allow(Facter::ClassDiscoverer).to receive(:instance).and_return(class_discoverer_mock)

        stub_const('Facts::Linux::Path::FACT_NAME', 'path')
      end

      it 'loads no legacy facts' do
        expect(internal_fact_loader.legacy_facts).to be_empty
      end

      it 'loads one core fact' do
        expect(internal_fact_loader.core_facts.size).to eq(1)
      end

      it 'loads one fact with :core type' do
        expect(internal_fact_loader.core_facts.first.type).to eq(:core)
      end
    end

    context 'when loading one legacy fact and one core fact' do
      before do
        allow(os_detector_mock).to receive(:hierarchy).and_return([:Windows])
        allow(OsDetector).to receive(:instance).and_return(os_detector_mock)

        allow(class_discoverer_mock)
          .to receive(:discover_classes)
          .with(:Windows)
          .and_return([Facts::Windows::NetworkInterfaces, Facts::Windows::Path])
        allow(Facter::ClassDiscoverer).to receive(:instance).and_return(class_discoverer_mock)

        stub_const('Facts::Windows::NetworkInterface::FACT_NAME', 'network_.*')
        stub_const('Facts::Windows::OsName::FACT_NAME', 'path')
      end

      it 'loads two facts' do
        expect(internal_fact_loader.facts.size).to eq(2)
      end

      it 'loads one legacy fact' do
        expect(internal_fact_loader.facts.count { |lf| lf.type == :legacy }).to eq(1)
      end

      it 'loads one core fact' do
        expect(internal_fact_loader.facts.count { |lf| lf.type == :core }).to eq(1)
      end
    end

    context 'when loading no facts' do
      before do
        allow(class_discoverer_mock)
          .to receive(:discover_classes)
          .with(:Linux)
          .and_return([])
        allow(Facter::ClassDiscoverer).to receive(:instance).and_return(class_discoverer_mock)
      end

      it 'loads no facts' do
        expect(internal_fact_loader.facts).to be_empty
      end
    end

    context 'when loading hierarchy of facts' do
      before do
        allow(os_detector_mock).to receive(:hierarchy).and_return(%i[Linux Rhel])
        allow(OsDetector).to receive(:instance).and_return(os_detector_mock)

        allow(class_discoverer_mock)
          .to receive(:discover_classes)
          .with(:Linux)
          .and_return([Facts::Linux::Os::Family])
        allow(class_discoverer_mock)
          .to receive(:discover_classes)
          .with(:Rhel)
          .and_return([Facts::Rhel::Os::Family])
        allow(Facter::ClassDiscoverer).to receive(:instance).and_return(class_discoverer_mock)

        stub_const('Facts::Linux::Path::FACT_NAME', 'os.family')
        stub_const('Facts::Rhel::Path::FACT_NAME', 'os.family')
      end

      it 'loads one fact' do
        core_facts = internal_fact_loader.facts.select { |loaded_fact| loaded_fact.type == :core }

        expect(core_facts.size).to eq(1)
      end

      it 'loads os.family fact' do
        core_facts = internal_fact_loader.facts.select { |loaded_fact| loaded_fact.type == :core }

        expect(core_facts.first.name).to eq('os.family')
      end

      it 'loads only Rhel path' do
        core_facts = internal_fact_loader.facts.select { |loaded_fact| loaded_fact.type == :core }

        expect(core_facts.first.klass).to eq(Facts::Rhel::Os::Family)
      end
    end

    context 'when loading fact with aliases' do
      before do
        allow(class_discoverer_mock)
          .to receive(:discover_classes)
          .with(:Linux)
          .and_return([Facts::Linux::Os::Name])
        allow(Facter::ClassDiscoverer).to receive(:instance).and_return(class_discoverer_mock)

        stub_const('Facts::Linux::Os::Name::FACT_NAME', 'os.name')
        stub_const('Facts::Linux::Os::Name::ALIASES', 'operatingsystem')
      end

      it 'loads two facts' do
        expect(internal_fact_loader.facts.size).to eq(2)
      end

      it 'loads one core fact' do
        expect(internal_fact_loader.core_facts.size).to eq(1)
      end

      it 'loads one legacy fact' do
        expect(internal_fact_loader.legacy_facts.size).to eq(1)
      end

      it 'loads a core fact with the fact name' do
        expect(internal_fact_loader.core_facts.first.name).to eq('os.name')
      end

      it 'loads a legacy fact with the alias name' do
        expect(internal_fact_loader.legacy_facts.first.name).to eq('operatingsystem')
      end
    end

    context 'when loading wildcard facts' do
      before do
        allow(os_detector_mock).to receive(:hierarchy).and_return([:Windows])
        allow(OsDetector).to receive(:instance).and_return(os_detector_mock)

        allow(class_discoverer_mock)
          .to receive(:discover_classes)
          .with(:Windows)
          .and_return([Facts::Windows::NetworkInterfaces])
        allow(Facter::ClassDiscoverer).to receive(:instance).and_return(class_discoverer_mock)

        stub_const('Facts::Windows::NetworkInterfaces::FACT_NAME', 'network_.*')
      end

      it 'loads one fact' do
        expect(internal_fact_loader.facts.size).to eq(1)
      end

      it 'loads one legacy fact' do
        expect(internal_fact_loader.legacy_facts.size).to eq(1)
      end

      it 'contains a wildcard at the end' do
        expect(internal_fact_loader.legacy_facts.first.name).to end_with('.*')
      end

      it 'loads no core facts' do
        expect(internal_fact_loader.core_facts).to be_empty
      end
    end

    context 'when loading legacy fact without wildcard' do
      before do
        allow(class_discoverer_mock)
          .to receive(:discover_classes)
          .with(:Linux)
          .and_return([Facts::Debian::Lsbdistid])
        allow(Facter::ClassDiscoverer).to receive(:instance).and_return(class_discoverer_mock)

        stub_const('Facts::Debian::Lsbdistid::FACT_NAME', 'lsbdistid')
      end

      it 'loads one fact' do
        expect(internal_fact_loader.facts.size).to eq(1)
      end

      it 'loads one legacy fact' do
        expect(internal_fact_loader.legacy_facts.size).to eq(1)
      end

      it 'does not contain a wildcard at the end' do
        expect(internal_fact_loader.legacy_facts.first.name).not_to end_with('.*')
      end

      it 'loads no core facts' do
        expect(internal_fact_loader.core_facts).to be_empty
      end
    end
  end
end
