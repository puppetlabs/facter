# frozen_string_literal: true

describe 'Facter' do
  let(:fact_name) { 'os.name' }
  let(:fact_value) { 'ubuntu' }
  let(:os_fact) { double(Facter::ResolvedFact, name: fact_name, value: fact_value, user_query: '', filter_tokens: []) }
  let(:fact_collection) { { 'os' => { 'name' => 'Ubuntu' } } }
  let(:empty_fact_collection) { {} }

  before do
    allow(Facter::CacheManager).to receive(:invalidate_all_caches)
  end

  describe '#to_hash' do
    it 'returns one resolved fact' do
      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([os_fact])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([os_fact])
        .and_return(fact_collection)

      resolved_facts_hash = Facter.to_hash
      expect(resolved_facts_hash).to eq(fact_collection)
    end

    it 'return no resolved facts' do
      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([])
        .and_return(empty_fact_collection)

      resolved_facts_hash = Facter.to_hash
      expect(resolved_facts_hash).to eq(empty_fact_collection)
    end
  end

  describe '#to_user_output' do
    it 'returns one fact' do
      user_query = 'os.name'
      options = {}
      expected_json_output = '{"os" : {"name": "ubuntu"}'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([os_fact])

      json_fact_formatter = double(Facter::JsonFactFormatter)
      allow(json_fact_formatter).to receive(:format).with([os_fact]).and_return(expected_json_output)

      allow(Facter::FormatterFactory).to receive(:build).with(options).and_return(json_fact_formatter)

      formated_facts = Facter.to_user_output({}, [user_query])
      expect(formated_facts).to eq(expected_json_output)
    end

    it 'returns no facts' do
      user_query = 'os.name'
      options = {}
      expected_json_output = '{}'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([])

      json_fact_formatter = double(Facter::JsonFactFormatter)
      allow(json_fact_formatter).to receive(:format).with([]).and_return(expected_json_output)

      allow(Facter::FormatterFactory).to receive(:build).with(options).and_return(json_fact_formatter)

      formatted_facts = Facter.to_user_output({}, [user_query])
      expect(formatted_facts).to eq(expected_json_output)
    end
  end

  describe '#value' do
    it 'returns a value' do
      user_query = 'os.name'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([os_fact])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([os_fact])
        .and_return(fact_collection)

      resolved_facts_hash = Facter.value(user_query)
      expect(resolved_facts_hash).to eq('Ubuntu')
    end

    it 'return no value' do
      user_query = 'os.name'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([])
        .and_return(empty_fact_collection)

      resolved_facts_hash = Facter.value(user_query)
      expect(resolved_facts_hash).to be nil
    end
  end

  describe '#core_value' do
    it 'searched in core facts and returns a value' do
      user_query = 'os.name'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_core).and_return([os_fact])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([os_fact])
        .and_return(fact_collection)

      resolved_facts_hash = Facter.core_value(user_query)
      expect(resolved_facts_hash).to eq('Ubuntu')
    end

    it 'searches ion core facts and return no value' do
      user_query = 'os.name'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_core).and_return([])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([])
        .and_return(empty_fact_collection)

      resolved_facts_hash = Facter.core_value(user_query)
      expect(resolved_facts_hash).to be nil
    end
  end
end
