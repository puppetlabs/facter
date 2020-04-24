# frozen_string_literal: true

describe Facter::FactManager do
  let(:internal_manager) { instance_spy(Facter::InternalFactManager) }
  let(:external_manager) { instance_spy(Facter::ExternalFactManager) }
  let(:cache_manager) { instance_spy(Facter::CacheManager) }

  before do
    Singleton.__init__(Facter::FactManager)
    allow(Facter::InternalFactManager).to receive(:new).and_return(internal_manager)
    allow(Facter::ExternalFactManager).to receive(:new).and_return(external_manager)
    allow(Facter::CacheManager).to receive(:new).and_return(cache_manager)
  end

  describe '#resolve_facts' do
    it 'resolved all facts' do
      ubuntu_os_name = double(Facts::Debian::Os::Name)
      user_query = []

      loaded_fact_os_name = double(Facter::LoadedFact, name: 'os.name', klass: ubuntu_os_name, type: :core)
      loaded_fact_custom_fact = double(Facter::LoadedFact, name: 'custom_fact', klass: nil, type: :custom)
      loaded_facts = [loaded_fact_os_name, loaded_fact_custom_fact]

      allow(Facter::FactLoader.instance).to receive(:load).and_return(loaded_facts)

      searched_fact1 = double(Facter::SearchedFact, name: 'os', fact_class: ubuntu_os_name, filter_tokens: [],
                                                    user_query: '', type: :core)
      searched_fact2 = double(Facter::SearchedFact, name: 'my_custom_fact', fact_class: nil, filter_tokens: [],
                                                    user_query: '', type: :custom)

      resolved_fact = mock_resolved_fact('os', 'Ubuntu', '', [])

      seached_facts = [searched_fact1, searched_fact2]

      allow(Facter::QueryParser)
        .to receive(:parse)
        .with(user_query, loaded_facts)
        .and_return(seached_facts)

      allow(internal_manager)
        .to receive(:resolve_facts)
        .with(seached_facts)
        .and_return([resolved_fact])

      allow(external_manager)
        .to receive(:resolve_facts)
        .with(seached_facts)

      allow(cache_manager)
        .to receive(:resolve_facts)
        .with(seached_facts)
        .and_return([seached_facts, []])

      allow(cache_manager)
        .to receive(:cache_facts)
        .with([resolved_fact])

      resolved_facts = Facter::FactManager.instance.resolve_facts(user_query)

      expect(resolved_facts).to eq([resolved_fact])
    end
  end

  describe '#resolve_core' do
    it 'resolves all core facts' do
      ubuntu_os_name = double(Facts::Debian::Os::Name)
      user_query = []

      loaded_fact_os_name = double(Facter::LoadedFact, name: 'os.name', klass: ubuntu_os_name, type: :core)
      loaded_facts = [loaded_fact_os_name]

      allow(Facter::FactLoader.instance).to receive(:load).and_return(loaded_facts)
      allow(Facter::FactLoader.instance).to receive(:internal_facts).and_return(loaded_facts)

      searched_fact = double(Facter::SearchedFact, name: 'os', fact_class: ubuntu_os_name, filter_tokens: [],
                                                   user_query: '', type: :core)

      resolved_fact = mock_resolved_fact('os', 'Ubuntu', '', [])

      allow(Facter::QueryParser)
        .to receive(:parse)
        .with(user_query, loaded_facts)
        .and_return([searched_fact])

      allow(internal_manager)
        .to receive(:resolve_facts)
        .with([searched_fact])
        .and_return([resolved_fact])

      resolved_facts = Facter::FactManager.instance.resolve_core(user_query)
      expect(resolved_facts).to eq([resolved_fact])
    end
  end
end
