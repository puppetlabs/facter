# frozen_string_literal: true

describe 'FactManager' do
  describe '#resolve_facts' do
    it 'resolved all facts' do
      ubuntu_os_name = double(Facter::Debian::OsName)
      user_query = []

      options = Facter::Options.instance
      options.refresh

      loaded_fact_os_name = double(Facter::LoadedFact, name: 'os.name', klass: ubuntu_os_name, type: :core)
      loaded_fact_custom_fact = double(Facter::LoadedFact, name: 'custom_fact', klass: nil, type: :custom)
      loaded_facts = [loaded_fact_os_name, loaded_fact_custom_fact]

      allow_any_instance_of(Facter::FactLoader).to receive(:load).and_return(loaded_facts)

      searched_fact1 = double(Facter::SearchedFact, name: 'os', fact_class: ubuntu_os_name, filter_tokens: [],
                                                    user_query: '', type: :core)
      searched_fact2 = double(Facter::SearchedFact, name: 'my_custom_fact', fact_class: nil, filter_tokens: [],
                                                    user_query: '', type: :custom)

      resolved_fact = mock_resolved_fact('os', 'Ubuntu', '', [])

      allow(Facter::QueryParser)
        .to receive(:parse)
        .with(user_query, loaded_facts)
        .and_return([searched_fact1, searched_fact2])

      allow_any_instance_of(Facter::InternalFactManager)
        .to receive(:resolve_facts)
        .with([searched_fact1, searched_fact2])
        .and_return([resolved_fact])

      allow_any_instance_of(Facter::ExternalFactManager)
        .to receive(:resolve_facts)
        .with([searched_fact1, searched_fact2])

      resolved_facts = Facter::FactManager.instance.resolve_facts(options, user_query)

      expect(resolved_facts).to eq([resolved_fact])
    end
  end

  describe '#resolve_core' do
    it 'resolves all core facts' do
      ubuntu_os_name = double(Facter::Debian::OsName)
      user_query = []

      loaded_fact_os_name = double(Facter::LoadedFact, name: 'os.name', klass: ubuntu_os_name, type: :core)
      loaded_facts = [loaded_fact_os_name]

      # allow_any_instance_of(Facter::InternalFactLoader).to receive(:core_facts).and_return(loaded_facts)
      allow_any_instance_of(Facter::FactLoader).to receive(:load).and_return(loaded_facts)
      allow_any_instance_of(Facter::FactLoader).to receive(:internal_facts).and_return(loaded_facts)

      searched_fact = double(Facter::SearchedFact, name: 'os', fact_class: ubuntu_os_name, filter_tokens: [],
                                                   user_query: '', type: :core)

      resolved_fact = mock_resolved_fact('os', 'Ubuntu', '', [])

      allow(Facter::QueryParser)
        .to receive(:parse)
        .with(user_query, loaded_facts)
        .and_return([searched_fact])

      allow_any_instance_of(Facter::InternalFactManager)
        .to receive(:resolve_facts)
        .with([searched_fact])
        .and_return([resolved_fact])

      resolved_facts = Facter::FactManager.instance.resolve_core(user_query)
      expect(resolved_facts).to eq([resolved_fact])
    end
  end
end
