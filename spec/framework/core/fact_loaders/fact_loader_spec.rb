# frozen_string_literal: true

describe 'FactLoader' do
  describe '#load' do
    let(:internal_fact_loader_double) { double(Facter::InternalFactLoader) }
    let(:external_fact_loader_double) { double(Facter::ExternalFactLoader) }

    let(:ubuntu_os_name) { double(Facter::Ubuntu::OsName) }
    let(:networking_class) { double(Facter::Ubuntu::NetworkInterface) }

    let(:loaded_fact_os_name) { double(Facter::LoadedFact, name: 'os.name', klass: ubuntu_os_name, type: :core) }
    let(:loaded_fact_networking) do
      double(Facter::LoadedFact, name: 'ipaddress_.*', klass: networking_class, type: :legacy)
    end
    let(:loaded_fact_custom_fact) { double(Facter::LoadedFact, name: 'custom_fact', klass: nil, type: :custom) }

    before(:each) do
      Singleton.__init__(Facter::FactLoader)

      allow(Facter::InternalFactLoader).to receive(:new).and_return(internal_fact_loader_double)
      allow(Facter::ExternalFactLoader).to receive(:new).and_return(external_fact_loader_double)
    end

    it 'loads all internal facts' do
      options = { user_query: true }

      facts_to_load = [loaded_fact_os_name, loaded_fact_networking]

      allow(internal_fact_loader_double).to receive(:facts).and_return(facts_to_load)
      allow(external_fact_loader_double).to receive(:custom_facts).and_return([])
      allow(external_fact_loader_double).to receive(:external_facts).and_return([])

      loaded_facts = Facter::FactLoader.instance.load(options)
      expect(loaded_facts).to eq(facts_to_load)
    end

    it 'loads core facts' do
      options = {}

      facts_to_load = [loaded_fact_os_name]

      allow(internal_fact_loader_double).to receive(:core_facts).and_return(facts_to_load)
      allow(external_fact_loader_double).to receive(:custom_facts).and_return([])
      allow(external_fact_loader_double).to receive(:external_facts).and_return([])

      loaded_facts = Facter::FactLoader.instance.load(options)
      expect(loaded_facts).to eq(facts_to_load)
    end
  end
end
