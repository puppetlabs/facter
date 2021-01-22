# frozen_string_literal: true

describe Facter::FactLoader do
  describe '#load' do
    let(:internal_fact_loader_double) { instance_spy(Facter::InternalFactLoader) }
    let(:external_fact_loader_double) { instance_spy(Facter::ExternalFactLoader) }

    let(:ubuntu_os_name) { instance_spy(Facts::Linux::Os::Name) }
    let(:networking_class) { instance_spy(Facts::Windows::NetworkInterfaces) }

    let(:loaded_fact_os_name) { instance_spy(Facter::LoadedFact, name: 'os.name', klass: ubuntu_os_name, type: :core) }
    let(:loaded_fact_os_name_legacy) do
      instance_spy(Facter::LoadedFact, name: 'operatingsystem', klass: ubuntu_os_name,
                                       type: :legacy)
    end
    let(:loaded_fact_networking) do
      instance_spy(Facter::LoadedFact, name: 'network_.*', klass: networking_class, type: :legacy)
    end
    let(:loaded_fact_custom_fact) { instance_spy(Facter::LoadedFact, name: 'custom_fact', klass: nil, type: :custom) }

    let(:loaded_env_custom_fact) do
      instance_spy(Facter::LoadedFact, name: 'os.name', klass: nil,
                                       type: :external, is_env: true)
    end

    before do
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

    it 'blocks one internal fact' do
      options = { blocked_facts: ['os.name'] }

      facts_to_load = [loaded_fact_os_name, loaded_fact_os_name_legacy]

      allow(internal_fact_loader_double).to receive(:core_facts).and_return(facts_to_load)
      allow(external_fact_loader_double).to receive(:custom_facts).and_return([])
      allow(external_fact_loader_double).to receive(:external_facts).and_return([])

      loaded_facts = Facter::FactLoader.instance.load(options)
      expect(loaded_facts.size).to eq(0)
    end

    it 'blocks one legacy fact' do
      options = { blocked_facts: ['operatingsystem'] }

      facts_to_load = [loaded_fact_os_name, loaded_fact_os_name_legacy]

      allow(internal_fact_loader_double).to receive(:core_facts).and_return(facts_to_load)
      allow(external_fact_loader_double).to receive(:custom_facts).and_return([])
      allow(external_fact_loader_double).to receive(:external_facts).and_return([])

      loaded_facts = Facter::FactLoader.instance.load(options)
      expect(loaded_facts.size).to eq(1)
    end

    context 'when blocking custom facts' do
      before do
        facts_to_load = [loaded_fact_custom_fact]

        allow(internal_fact_loader_double).to receive(:core_facts).and_return([])
        allow(external_fact_loader_double).to receive(:custom_facts).and_return(facts_to_load)
        allow(external_fact_loader_double).to receive(:external_facts).and_return([])
      end

      it 'blocks one custom fact' do
        options = { custom_facts: true, blocked_facts: ['custom_fact'] }
        loaded_facts = Facter::FactLoader.instance.load(options)

        expect(loaded_facts.size).to eq(0)
      end
    end

    it 'loads the same amount of core facts everytime' do
      options = { user_query: true }

      facts_to_load = [loaded_fact_os_name, loaded_fact_networking]

      allow(internal_fact_loader_double).to receive(:facts).and_return(facts_to_load)
      allow(external_fact_loader_double).to receive(:custom_facts).and_return([])
      allow(external_fact_loader_double).to receive(:external_facts).and_return([])

      loaded_facts1 = Facter::FactLoader.instance.load(options)
      loaded_facts2 = Facter::FactLoader.instance.load(options)
      expect(loaded_facts1).to eq(loaded_facts2)
    end

    it 'loads the same amount of custom facts everytime' do
      options = { blocked_facts: ['os.name'], custom_facts: true }

      facts_to_load = [loaded_fact_os_name]

      allow(internal_fact_loader_double).to receive(:core_facts).and_return(facts_to_load)
      allow(external_fact_loader_double).to receive(:custom_facts).and_return(facts_to_load)
      allow(external_fact_loader_double).to receive(:external_facts).and_return([])

      loaded_facts1 = Facter::FactLoader.instance.load(options)
      loaded_facts2 = Facter::FactLoader.instance.load(options)
      expect(loaded_facts1).to eq(loaded_facts2)
    end

    it 'env facts override core facts' do
      options = { external_facts: true }

      allow(internal_fact_loader_double).to receive(:core_facts).and_return([loaded_fact_os_name])
      allow(external_fact_loader_double).to receive(:custom_facts).and_return([])
      allow(external_fact_loader_double).to receive(:external_facts).and_return([loaded_env_custom_fact])

      loaded_facts = Facter::FactLoader.instance.load(options)
      expect(loaded_facts).to be_an_instance_of(Array).and contain_exactly(
        loaded_env_custom_fact
      )
    end

    context 'when blocking legacy group' do
      before do
        facts_to_load = [loaded_fact_os_name_legacy]

        allow(internal_fact_loader_double).to receive(:core_facts).and_return(facts_to_load)
        allow(external_fact_loader_double).to receive(:custom_facts).and_return([])
        allow(external_fact_loader_double).to receive(:external_facts).and_return([])
      end

      let(:options) { { block_list: 'legacy' } }

      it 'blocks legacy facts' do
        loaded_facts = Facter::FactLoader.instance.load(options)

        expect(loaded_facts).to be_empty
      end
    end
  end
end
