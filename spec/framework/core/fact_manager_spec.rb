# frozen_string_literal: true

describe 'FactManager' do
  describe '#resolve_facts' do
    it 'resolved all facts' do
      ubuntu_os_name = double(Facter::Ubuntu::OsName)
      user_query = []
      options = {}

      core_facts = { 'os' => ubuntu_os_name }
      custom_facts = { 'my_custom_fact' => nil }
      loaded_facts = core_facts.merge(custom_facts)

      allow_any_instance_of(Facter::InternalFactLoader).to receive(:core_facts).and_return(core_facts)
      allow_any_instance_of(Facter::ExternalFactLoader).to receive(:facts).and_return(custom_facts)

      searched_fact1 =
        double(Facter::SearchedFact, name: 'os', fact_class: ubuntu_os_name, filter_tokens: [], user_query: '')
      searched_fact2 =
        double(Facter::SearchedFact, name: 'my_custom_fact', fact_class: nil, filter_tokens: [], user_query: '')

      resolved_fact = mock_resolved_fact('os', 'Ubuntu', '', [])

      allow(Facter::QueryParser)
        .to receive(:parse)
        .with(user_query, loaded_facts)
        .and_return([searched_fact1, searched_fact2])

      allow_any_instance_of(Facter::CoreFactManager)
        .to receive(:resolve_facts)
        .with([searched_fact1])
        .and_return([resolved_fact])

      allow_any_instance_of(Facter::CustomFactManager).to receive(:resolve_facts).with([searched_fact2])

      resolved_facts = Facter::FactManager.instance.resolve_facts(options, user_query)

      expect(resolved_facts).to eq([resolved_fact])
    end
  end

  describe '#resolve_core' do
    it 'resolves all core facts' do
      ubuntu_os_name = double(Facter::Ubuntu::OsName)
      core_facts = { 'os' => ubuntu_os_name }
      user_query = []
      options = {}

      allow_any_instance_of(Facter::InternalFactLoader).to receive(:core_facts).and_return(core_facts)

      searched_fact =
        double(Facter::SearchedFact, name: 'os', fact_class: ubuntu_os_name, filter_tokens: [], user_query: '')
      resolved_fact = mock_resolved_fact('os', 'Ubuntu', '', [])

      allow(Facter::QueryParser)
        .to receive(:parse)
        .with(user_query, core_facts)
        .and_return([searched_fact])

      allow_any_instance_of(Facter::CoreFactManager)
        .to receive(:resolve_facts)
        .with([searched_fact])
        .and_return([resolved_fact])

      resolved_facts = Facter::FactManager.instance.resolve_core(options, user_query)
      expect(resolved_facts).to eq([resolved_fact])
    end
  end
end
