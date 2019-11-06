# frozen_string_literal: true

describe 'InternalFactLoader' do
  before do
    allow_any_instance_of(CurrentOs).to receive(:hierarchy).and_return([:Ubuntu])
  end

  describe '#initialize' do
    context 'load facts' do
      it 'loads one legacy fact' do
        allow_any_instance_of(Facter::ClassDiscoverer)
          .to receive(:discover_classes)
          .with(:Ubuntu)
          .and_return([:NetworkInterface])

        stub_const('Facter::Ubuntu::NetworkInterface::FACT_NAME', 'ipaddress_.*')

        internal_fact_loader = Facter::InternalFactLoader.new
        legacy_facts = internal_fact_loader.legacy_facts

        expect(legacy_facts.size).to eq(1)
        expect(legacy_facts.first.type).to eq(:legacy)
      end

      it 'loads one core fact' do
        allow_any_instance_of(Facter::ClassDiscoverer)
          .to receive(:discover_classes)
          .with(:Ubuntu)
          .and_return([:OsName])

        stub_const('Facter::Ubuntu::OsName::FACT_NAME', 'os.name')

        internal_fact_loader = Facter::InternalFactLoader.new
        core_facts = internal_fact_loader.core_facts

        expect(core_facts.size).to eq(1)
        expect(core_facts.first.type).to eq(:core)
      end

      it 'loads one legacy fact and one core fact' do
        allow_any_instance_of(Facter::ClassDiscoverer)
          .to receive(:discover_classes)
          .with(:Ubuntu)
          .and_return(%i[NetworkInterface OsName])

        stub_const('Facter::Ubuntu::NetworkInterface::FACT_NAME', 'ipaddress_.*')
        stub_const('Facter::Ubuntu::OsName::FACT_NAME', 'os.name')

        internal_fact_loader = Facter::InternalFactLoader.new
        all_facts = internal_fact_loader.facts

        expect(all_facts.size).to eq(2)
        expect(all_facts.first.type).to eq(:legacy)
        all_facts.shift
        expect(all_facts.first.type).to eq(:core)
      end

      it 'loads no facts' do
        allow_any_instance_of(Facter::ClassDiscoverer)
          .to receive(:discover_classes)
          .with(:Ubuntu)
          .and_return([])
        internal_fact_loader = Facter::InternalFactLoader.new
        all_facts_hash = internal_fact_loader.facts

        expect(all_facts_hash.size).to eq(0)
      end
    end
  end
end
